<?
include '../config.php';
include '../db.php';
include '../nocache.php';
$_SERVER['REQUEST_METHOD']==='GET' || fail(405,'only GETs allowed here');
db("set search_path to answer_history,pg_temp");
ccdb("select login_answer(nullif($1,'')::uuid,nullif($2,'')::integer)",$_COOKIE['uuid']??'',$_GET['id']??'') || fail(403,'access denied');
extract(cdb("select account_id
                   ,answer_id,answer_is_imported
                   ,question_id,question_title
                   ,community_name,community_display_name,community_code_language,community_tables_are_monospace
                   ,my_community_regular_font_name,my_community_monospace_font_name
                   ,community_rgb_dark,community_rgb_mid,community_rgb_light,community_rgb_highlight,community_rgb_warning
                  , (select jsonb_agg(z)
                     from (select answer_history_id,account_id,account_name,answer_history_markdown,answer_history_at,prev_markdown,rn from history order by answer_history_at desc) z) items
             from one"));
$cookies = isset($_COOKIE['uuid'])?'Cookie: uuid='.$_COOKIE['uuid'].'; '.(isset($_COOKIE['environment'])?'environment='.$_COOKIE['environment'].'; ':''):'';
?>
<!doctype html>
<html style="--rgb-dark: <?=$community_rgb_dark?>;
             --rgb-mid: <?=$community_rgb_mid?>;
             --rgb-light: <?=$community_rgb_light?>;
             --rgb-highlight: <?=$community_rgb_highlight?>;
             --rgb-warning: <?=$community_rgb_warning?>;
             --rgb-white: 255, 255, 255;
             --rgb-black: 0, 0, 0;
             --regular-font-family: '<?=$my_community_regular_font_name?>', serif;
             --monospace-font-family: '<?=$my_community_monospace_font_name?>', monospace;
             --markdown-table-font-family: <?=$community_tables_are_monospace?"'".$my_community_monospace_font_name."', monospace":"'".$my_community_regular_font_name."', serif;"?>
             ">
<head>
  <link rel="stylesheet" href="/fonts/<?=$my_community_regular_font_name?>.css">
  <link rel="stylesheet" href="/fonts/<?=$my_community_monospace_font_name?>.css">
  <link rel="stylesheet" href="/lib/fork-awesome/css/fork-awesome.min.css">
  <link rel="stylesheet" href="/lib/lightbox2/css/lightbox.min.css">
  <link rel="stylesheet" href="/lib/codemirror/codemirror.css">
  <link rel="stylesheet" href="/global.css">
  <link rel="stylesheet" href="/header.css">
  <link rel="stylesheet" href="/post.css">
  <link rel="icon" href="/communityicon?community=<?=$community_name?>" type="image/png">
  <style>
    html { box-sizing: border-box; font-family: '<?=$my_community_regular_font_name?>', serif; }
    html, body { height: 100vh; overflow: hidden; margin: 0; padding: 0; scroll-behavior: smooth; }
    body { display: flex; flex-direction: column; background: rgb(var(--rgb-mid)); }
    main { display: grid; align-items: start; grid-template-columns: auto 1fr; grid-template-rows: max-content 1fr; overflow: hidden; flex: 1 0 0; }
    textarea, pre, code, .CodeMirror { font-family: '<?=$my_community_monospace_font_name?>', monospace; }

    .icon { width: 20px; height: 20px; display: block; margin: 1px; border-radius: 2px; }
    .when { font-size: 14px; color: rgb(var(--rgb-dark)); white-space: nowrap; }
    .diff { background: rgb(var(--rgb-light)); overflow-wrap: break-word; white-space: pre-wrap; font-family: monospace; padding: 8px; border: 1px solid rgba(var(--rgb-dark),0.6); border-radius: 3px; overflow-y: auto; max-height: 100%; }
    .markdown { background: rgb(var(--rgb-white)); padding: 8px; font-size: 16px; border: 1px solid rgba(var(--rgb-dark),0.6); border-radius: 3px; max-height: 100%; overflow-y: auto; }
    .editor-wrapper { height: 100%; overflow-y: auto; }

    #revisions { height: 100%; background: rgb(var(--rgb-light)); border-right: 1px solid rgba(var(--rgb-dark),0.6); font-size: 14px; overflow-y: auto; grid-area: 1 / 1 / 3 / 2; }
    #revisions > a { padding: 2px 2px 3px 5px; border-bottom: 1px solid rgba(var(--rgb-dark),0.6); display: grid; grid-template-rows: auto; grid-template-columns: auto 22px; grid-column-gap: 5px; cursor: pointer; color: unset; text-decoration: unset; }
    #revisions > a.active { box-shadow: 0 0 0 1px rgb(var(--rgb-highlight)) inset; }
    #history-bar { display: grid; grid-template-columns: auto 1fr auto; margin: 10px 10px 0 10px; font-size: 14px; grid-area: 1 / 2 / 2 / 3; }
    #history-bar > div { margin: 0; }
    #content { padding: 10px; grid-area: 2 / 2 / 3 / 3; overflow: hidden; height: 100%; }
    #content > div { overflow: hidden; height: 100%; position: relative; }
    #content > div:not(.active) { display: none; }
    #content .panel { display: grid; grid-template-rows: 1fr; grid-gap: 10px; align-items: start; overflow: hidden; width: 100%; height: 100%; position: absolute; top: 0; left: 0; }
    #content .diff-container { grid-template-columns: 1fr; }
    #content .before-container, #content .after-container { grid-template-columns: 1fr 1fr; visibility: hidden; }

    .CodeMirror { height: auto; border: 1px solid rgba(var(--rgb-dark),0.6); border-radius: 3px; }
    .CodeMirror pre.CodeMirror-placeholder { color: darkgrey; }
    .CodeMirror-wrap pre { word-break: break-word; }
  </style>
  <script src="/lib/js.cookie.js"></script>
  <script src="/lib/lodash.js"></script>
  <script src="/lib/jquery.js"></script>
  <script src="/lib/codemirror/codemirror.js"></script>
  <script src="/lib/codemirror/markdown.js"></script>
  <script src="/lib/codemirror/sql.js"></script>
  <?require '../markdown.php';?>
  <script src="/lib/moment.js"></script>
  <script src="/lib/diff_match_patch.js"></script>
  <script>
    $(function(){
      var dmp = new diff_match_patch();

      function render(){
        var promises = [];
        $(this).find('.diff').each(function(){
          var d = dmp.diff_main($(this).attr('data-from'),$(this).attr('data-to'));
          dmp.diff_cleanupSemantic(d);
          $(this).html(dmp.diff_prettyHtml(d));
        });
        $(this).children('div').children('textarea').each(function(){
          $(this).wrap('<div class="editor-wrapper"></div>');
          var markdown = $(this).parent().next(), cm = CodeMirror.fromTextArea($(this)[0],{ lineWrapping: true, readOnly: true }), map = [];
          markdown.attr('data-markdown',cm.getValue()).renderMarkdown(promises);
          markdown.find('[data-source-line]').each(function(){ map.push($(this).data('source-line')); });
          cm.on('scroll', _.throttle(function(){
            var rect = cm.getWrapperElement().getBoundingClientRect();
            var m = Math.round(cm.lineAtHeight(rect.top,"window")+cm.lineAtHeight(rect.bottom,"window"))/2;
            if(cm.getScrollInfo().top<10) markdown.animate({ scrollTop: 0 });
            else if(cm.getScrollInfo().top+10>(cm.getScrollInfo().height-cm.getScrollInfo().clientHeight)) markdown.animate({ scrollTop: markdown.prop("scrollHeight")-markdown.height() });
            else markdown.find('[data-source-line="'+map.reduce(function(prev,curr) { return ((Math.abs(curr-m)<Math.abs(prev-m))?curr:prev); })+'"]')[0].scrollIntoView({ behavior: 'smooth', block: 'center' });
          },200));
        });
        Promise.allSettled(promises).then(() => {
          $(this).find('.post:not(.processed) .when').each(function(){
            $(this).text(moment.duration($(this).data('seconds'),'seconds').humanize()+' ago');
            $(this).attr('title',moment($(this).data('at')).calendar(null, { sameDay: 'HH:mm', lastDay: '[Yesterday] HH:mm', lastWeek: '[Last] dddd HH:mm', sameElse: 'Do MMM YYYY HH:mm' }));
          });
          $(this).find('.post').addClass('processed');
        });
        $(this).addClass('rendered');
      }

      $('#revisions > a').click(function(){
        $('.active').removeClass('active');
        $(this).addClass('active');
        $('#content > div.'+$(this).attr('id')).addClass('active');
        $('#content > div.'+$(this).attr('id')+':not(.rendered)').each(render);
        history.replaceState(null,null,'#'+$(this).attr('id'));
        return false;
      });
      $('#history-bar a.panel').click(function(){
        var panels = $('#content div.panel'), panel = $('#content div.panel.'+$(this).data('panel'));
        $('#history-bar a.panel:not([href])').attr('href','.');
        $(this).removeAttr('href');
        panels.css('visibility','hidden');
        panel.css('visibility','visible');
        return false;
      });
      if($('#revisions > a:target').length){ $('#revisions > a:target').click(); }else{ $('#revisions > a:first-child').click(); }
    });
  </script>
  <title>Answer History - TopAnswers</title>
</head>
<body>
  <header>
    <?$ch = curl_init('http://127.0.0.1/navigation?community='.$community_name); curl_setopt($ch, CURLOPT_HTTPHEADER, [$cookies]); curl_exec($ch); curl_close($ch);?>
    <div class="container">
      <span class="element">history of <a href="/<?=$community_name?>?q=<?=$question_id?>#a<?=$answer_id?>">an answer</a> on the question <a href="/<?=$community_name?>?q=<?=$question_id?>"><?=$question_title?></a></span>
    </div>
    <div>
      <a class="frame" href="/profile?community=<?=$community_name?>" title="profile"><img class="icon" src="/identicon?id=<?=$account_id?>"></a>
    </div>
  </header>
  <main>
    <div id="revisions">
      <?foreach($items as $i=>$r){ extract($r, EXTR_PREFIX_ALL, 'h');?>
        <a id="h<?=$h_answer_history_id?>" href="#h<?=$h_answer_history_id?>">
          <div>
            <?=($h_rn===1)?($answer_is_imported?'Imported':'Answered'):'Edited'?> by <?=$h_account_name?>
            <div class="when"><?=$h_answer_history_at?></div>
          </div>
          <img class="icon" data-id="<?=$h_account_id?>" src="/identicon?id=<?=$h_account_id?>">
        </a>
      <?}?>
    </div>
    <div id="history-bar">
      <div>
        <a href="." class="panel" data-panel="before-container">before</a> / <a class="panel" data-panel="diff-container">diff</a> / <a href="." class="panel" data-panel="after-container">after</a>
      </div>
    </div>
    <div id="content">
      <?foreach($items as $i=>$r){ extract($r);?>
        <div class="h<?=$answer_history_id?>">
          <?if($rn>1){?>
            <div class="panel before-container">
              <textarea><?=$prev_markdown?></textarea>
              <div class="markdown"></div>
            </div>
          <?}?>
          <div class="panel diff-container">
            <div class="diff" data-from="<?=$prev_markdown?>" data-to="<?=$answer_history_markdown?>"></div>
          </div>
          <div class="panel after-container">
            <textarea><?=$answer_history_markdown?></textarea>
            <div class="markdown"></div>
          </div>
        </div>
      <?}?>
    </div>
  </main>
</body>   
</html>   

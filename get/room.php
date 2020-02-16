<?    
include '../db.php';
include '../nocache.php';
$_SERVER['REQUEST_METHOD']==='GET' || fail(405,'only GETs allowed here');
db("set search_path to room,pg_temp");
ccdb("select login_room(nullif($1,'')::uuid,nullif($2,'')::integer)",$_COOKIE['uuid']??'',$_GET['id']??'') || fail(403,'access denied');
extract(cdb("select account_id,room_id,room_name,room_has_image,community_name,my_community_regular_font_name,my_community_monospace_font_name
                   ,community_rgb_dark,community_rgb_mid,community_rgb_light,community_rgb_highlight,community_rgb_warning
             from one"));
?>
<!doctype html>
<html style="--rgb-dark: <?=$community_rgb_dark?>;
             --rgb-mid: <?=$community_rgb_mid?>;
             --rgb-light: <?=$community_rgb_light?>;
             --rgb-highlight: <?=$community_rgb_highlight?>;
             --rgb-warning: <?=$community_rgb_warning?>;
             --regular-font-family: '<?=$my_community_regular_font_name?>', serif;
             --monospace-font-family: '<?=$my_community_monospace_font_name?>', monospace;
             --markdown-table-font-family: <?=$community_tables_are_monospace?"'".$my_community_monospace_font_name."', monospace":"'".$my_community_regular_font_name."', serif;"?>
             ">
<head>
  <link rel="stylesheet" href="/fonts/<?=$my_community_regular_font_name?>.css">
  <link rel="stylesheet" href="/fonts/<?=$my_community_monospace_font_name?>.css">
  <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon">
  <link rel="icon" href="/favicon.ico" type="image/x-icon">
  <link rel="stylesheet" href="/global.css">
  <link rel="stylesheet" href="/header.css">
  <style>
    *:not(hr) { box-sizing: inherit; }
    html { box-sizing: border-box; font-family: '<?=$my_community_regular_font_name?>', serif; font-size: 16px; }
    body { display: flex; flex-direction: column; background: rgb(var(--rgb-dark)); }
    html, body { height: 100vh; overflow: hidden; margin: 0; padding: 0; }
    header, header>div { display: flex; min-width: 0; overflow: hidden; align-items: center; white-space: nowrap; }
    header { min-height: 30px; flex-wrap: wrap; justify-content: space-between; font-size: 14px; background: rgb(var(--rgb-dark)); white-space: nowrap; border-bottom: 2px solid black; }
    header a { color: rgb(var(--rgb-light)); }
    main { display: flex; flex-direction: column; align-items: flex-start; overflow: auto; scroll-behavior: smooth; }

    .frame { display: inline-block; border: 1px solid rgb(var(--rgb-dark)); margin: 2px; outline: 1px solid rgb(var(--rgb-light)); background-color: rgb(var(--rgb-light)); }
    .icon { width: 20px; height: 20px; display: block; margin: 1px; border-radius: 2px; }
    .element { margin: 0 4px; }

    fieldset { display: inline-block; margin: 16px; border: none; background-color: white; border-radius: 3px; }
    legend { background-color: white; box-shadow: 0 0 1px 1px rgb(var(--rgb-dark)); border-radius: 3px; padding: 2px 4px; }
  </style>
  <script src="/lib/jquery.js"></script>
  <script>
    $(function(){
    });
  </script>
  <title>Room | TopAnswers</title>
</head>
<body>
  <header>
    <div class="container">
      <a class="frame" style="background: white;" href="/" title="home"><img class="icon" src="/image?hash=cb8fe8c88f6b7326bcca667501eaf8b1f1e2ef46af1bc0c37eeb71daa477e1be"></a>
      <a class="element" href="/<?=$community_name?>">TopAnswers</a>
    </div>
    <div>
      <a class="frame" href="/profile?community=<?=$community_name?>" title="profile"><img class="icon" src="/identicon?id=<?=$account_id?>"></a>
    </div>
  </header>
  <main>
    <fieldset>
      <legend>name</legend>
      <form action="//post.topanswers.xyz/room" method="post">
        <input type="hidden" name="id" value="<?=$room_id?>">
        <input type="text" name="name" placeholder="name" value="<?=$room_name?>" autocomplete="off" autofocus>
        <input type="submit" value="Save">
      </form>
    </fieldset>
    <fieldset>
      <legend>picture</legend>
      <div class="frame"><img class="icon" src="/roomicon?id=<?=$room_id?>"></div>
      <?if($room_has_image){?>
        <form action="//post.topanswers.xyz/room" method="post">
          <input type="hidden" name="id" value="<?=$room_id?>">
          <input type="hidden" name="image">
          <input type="submit" value="Remove">
        </form>
      <?}?>
      <hr>
      <form action="//post.topanswers.xyz/room" method="post" enctype="multipart/form-data">
        <input type="hidden" name="id" value="<?=$room_id?>">
        <input type="file" name="image" accept=".png,.gif,.jpg,.jpeg">
        <input type="submit" value="Save">
      </form>
    </fieldset>
  </main>
</body>   
</html>   

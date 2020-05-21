create schema chat;
grant usage on schema chat to get,post;
set local search_path to chat,api,pg_temp;
--
--
create view one with (security_barrier) as
select community_language,room_id,room_can_chat
     , room_derived_name, room_derived_name room_name
from api._room natural join api._community
     natural left join (select account_id,account_is_dev from db.login natural join db.account where login_uuid=get_login_uuid()) a
where room_id=get_room_id();
--
--
create function login_room(uuid,integer) returns boolean language sql security definer as $$select * from api.login_room($1,$2);$$;
--
create function changes(integer) returns table (chat_id bigint, chat_change_id bigint) language sql security definer set search_path=db,api,chat,pg_temp as $$
  select chat_id,chat_change_id
  from (select chat_id,chat_change_id,exists(select 1 from api._chat a where a.chat_id=c.chat_id) e from chat c where room_id=get_room_id() and chat_change_id>$1) z
  where e
  limit 50;
$$;
--
create function range(startid bigint, endid bigint, lim integer = 100)
                     returns table (chat_id bigint
                                  , account_id integer
                                  , chat_reply_id integer
                                  , chat_markdown text
                                  , chat_at timestamptz
                                  , chat_change_id bigint
                                  , account_is_me boolean
                                  , account_name text
                                  , reply_account_name text
                                  , reply_account_is_me boolean
                                  , chat_gap integer
                                  , communicant_votes integer
                                  , chat_editable_age boolean
                                  , i_flagged boolean
                                  , i_starred boolean
                                  , chat_account_will_repeat boolean
                                  , chat_is_deleted boolean
                                  , chat_crew_flags integer
                                  , chat_flag_count integer
                                  , chat_star_count integer
                                  , chat_has_history boolean
                                  , chat_pings text
                                  , notification_id bigint
                                  , chat_account_is_repeat boolean
                                  , rn bigint
                                   ) language sql security definer set search_path=db,api,chat,pg_temp as $$
  with g as (select get_account_id() account_id, get_room_id() room_id)
    , cr as (select coalesce((select communicant_is_post_flag_crew from db.communicant c where c.account_id = g.account_id and community_id=get_community_id()),false) is_crew from g)
   , cc1 as (select *
             from chat
             where room_id=(select room_id from g) and startid is not null and endid is not null and chat_id>=startid and chat_id<=endid
                   and ((select is_crew from cr) or chat_crew_flags<0 or (((select account_id from g) is not null or chat_flags=0) and chat_crew_flags=0) or account_id=(select account_id from g))
             limit least(lim,251)+2)
   , cc2 as (select *
             from chat
             where room_id=(select room_id from g) and startid is null and endid is not null and chat_id<=endid
                   and ((select is_crew from cr) or chat_crew_flags<0 or (((select account_id from g) is not null or chat_flags=0) and chat_crew_flags=0) or account_id=(select account_id from g))
             order by chat_id desc
             limit least(lim,251)+1)
   , cc3 as (select *
             from chat
             where room_id=(select room_id from g) and startid is not null and endid is null and chat_id>=startid
                   and ((select is_crew from cr) or chat_crew_flags<0 or (((select account_id from g) is not null or chat_flags=0) and chat_crew_flags=0) or account_id=(select account_id from g))
             order by chat_id
             limit least(lim,251)+1)
   , cc4 as (select *
             from chat
             where room_id=(select room_id from g) and startid is null and endid is null
                   and ((select is_crew from cr) or chat_crew_flags<0 or (((select account_id from g) is not null or chat_flags=0) and chat_crew_flags=0) or account_id=(select account_id from g))
             order by chat_id desc
             limit least(lim,251))
    , cc as (select * from cc1 union all select * from cc2 union all select * from cc3 union all select * from cc4)
     , c as (select *, row_number() over(order by chat_at desc) rn
             from (select *, (lead(account_id) over (order by chat_at desc)) is not distinct from account_id and chat_reply_id is null and chat_gap<60 chat_account_is_repeat
                   from (select *, round(extract('epoch' from chat_at-(lead(chat_at) over (order by chat_at desc))))::integer chat_gap from cc) z) z
             where startid=endid or ((chat_id>startid or startid is null) and (chat_id<endid or endid is null)))
  select chat_id,account_id,chat_reply_id,chat_markdown,chat_at,chat_change_id
       , account_id=(select account_id from g) account_is_me
       , coalesce(nullif(account_name,''),'Anonymous') account_name
       , (select coalesce(nullif(account_name,''),'Anonymous') from chat natural join account where chat_id=c.chat_reply_id) reply_account_name
       , (select account_id=(select account_id from g) from chat natural join account where chat_id=c.chat_reply_id) reply_account_is_me
       , chat_gap
       , coalesce(communicant_votes,0) communicant_votes
       , extract('epoch' from current_timestamp-chat_at)<240 chat_editable_age
       , exists(select 1 from chat_flag where chat_id=c.chat_id and account_id=(select account_id from g) and chat_flag_direction>0) i_flagged
       , exists(select 1 from chat_star where chat_id=c.chat_id and account_id=(select account_id from g)) i_starred
       , (lead(account_id) over (order by chat_at desc)) is not distinct from account_id and chat_reply_id is null and (lead(chat_reply_id) over (order by chat_at desc)) is null chat_account_will_repeat
       , chat_crew_flags>0 chat_is_deleted
       , chat_crew_flags
       , chat_flags+chat_crew_flags chat_flag_count
       , (select count(1)::integer from chat_star where chat_id=c.chat_id) chat_star_count
       , (select count(1) from chat_history where chat_id=c.chat_id)>1 chat_has_history
       , (select json_agg(p.account_id) from ping p where p.chat_id=c.chat_id and c.account_id=get_account_id())::text chat_pings
       , notification_id
       , chat_account_is_repeat
       , rn
  from c
       natural join account
       natural join (select account_id,community_id,communicant_votes from communicant) v
       natural left join (select chat_id,notification_id from chat_notification natural join notification where account_id=get_account_id() and notification_dismissed_at is null) n
  order by rn;
$$;
--
create function quote(rid integer, cid bigint) returns text language sql security definer set search_path=db,api,chat,pg_temp as $$
  select _error('invalid chat id') where not exists (select 1 from _chat where chat_id=cid);
  select _error('invalid room id') where not exists (select 1 from _room where room_id=rid);
  --
  select '::: quote '||room_id||' '||cid||' '||account_id||' '||community_rgb_mid||' '||community_rgb_dark||chr(10)
         ||account_derived_name||(case when reply_account_name is not null then ' replying to '||reply_account_name else '' end)
           ||(case when room_id<>rid and room_question_id is not null then chat_iso||' *in ['||room_derived_name||'](/'||community_name||'?q='||room_question_id||'#c'||cid||')*'
                   when room_id<>rid then chat_iso||' *in ['||room_derived_name||'](/'||community_name||'?room='||room_id||'#c'||cid||')*'
                   else '['||chat_iso||'](#c'||cid||')' end)||'  '||chr(10)
         ||regexp_replace(chat_markdown,'^','>','mg')||chr(10)
         ||':::'
  from (select chat_reply_id,room_id,room_question_id,room_derived_name,community_name,community_rgb_mid,community_rgb_dark,chat_at,chat_markdown,account_id,account_derived_name
             , to_char(chat_at,'YYYY-MM-DD"T"HH24:MI:SS"Z"') chat_iso
        from chat natural join api._community natural join community natural join api._account natural join db.room natural join api._room
        where chat_id=cid) c
       natural left join (select chat_id chat_reply_id, account_derived_name reply_account_name from chat natural join api._account) r
$$;
--
create function recent() returns bigint language sql security definer set search_path=db,api,chat,pg_temp as $$
  select greatest(min(chat_id)-1,0) from (select chat_id from chat where room_id=get_room_id() order by chat_id desc limit 100) z;
$$;
--
--
revoke all on all functions in schema chat from public;
do $$
begin
  execute (select string_agg('grant select on '||viewname||' to get;', E'\n') from pg_views where schemaname='chat' and viewname!~'^_');
  execute ( select string_agg('grant execute on function '||p.oid::regproc||'('||pg_get_function_identity_arguments(p.oid)||') to get;', E'\n')
            from pg_proc p join pg_namespace n on p.pronamespace=n.oid
            where n.nspname='chat' and proname!~'^_' );
end$$;
--
--
create function new(msg text, replyid integer, pingids integer[]) returns bigint language sql security definer set search_path=db,api,pg_temp as $$
  select _error('access denied') where not exists(select 1 from api._room where room_id=get_room_id() and room_can_chat);
  select _error(413,'message too long') where length(msg)>5000;
  select _ensure_communicant(get_account_id(),community_id) from room where room_id=get_room_id();
  --
  with d as (update notification set notification_dismissed_at = current_timestamp where notification_id in(select notification_id from notification natural join chat_notification where chat_id=replyid and account_id=get_account_id()) returning *)
  update account set account_notification_id = default from d where account.account_id=d.account_id;
  --
  insert into chat_year(room_id,chat_year,chat_year_count)
  select get_room_id(),extract('year' from current_timestamp),1 from room where room_id=get_room_id() on conflict on constraint chat_year_pkey do update set chat_year_count = chat_year.chat_year_count+1;
  --
  insert into chat_month(room_id,chat_year,chat_month,chat_month_count)
  select get_room_id(),extract('year' from current_timestamp),extract('month' from current_timestamp),1 from room where room_id=get_room_id()
  on conflict on constraint chat_month_pkey do update set chat_month_count = chat_month.chat_month_count+1;
  --
  insert into chat_day(room_id,chat_year,chat_month,chat_day,chat_day_count)
  select get_room_id(),extract('year' from current_timestamp),extract('month' from current_timestamp),extract('day' from current_timestamp),1 from room where room_id=get_room_id()
  on conflict on constraint chat_day_pkey do update set chat_day_count = chat_day.chat_day_count+1;
  --
  insert into chat_hour(room_id,chat_year,chat_month,chat_day,chat_hour,chat_hour_count)
  select get_room_id(),extract('year' from current_timestamp),extract('month' from current_timestamp),extract('day' from current_timestamp),extract('hour' from current_timestamp),1 from room where room_id=get_room_id()
  on conflict on constraint chat_hour_pkey do update set chat_hour_count = chat_hour.chat_hour_count+1;
  --
  with i as (insert into chat(community_id,room_id,account_id,chat_markdown,chat_reply_id)
             select community_id,get_room_id(),get_account_id(),msg,replyid from room where room_id=get_room_id() returning community_id,room_id,chat_id)
    , rm as (update room r set room_latest_chat_id=i.chat_id from i where r.room_id=i.room_id)
     , h as (insert into chat_history(chat_id,chat_history_markdown) select chat_id,msg from i)
    , aa as (select account_id from (select account_id from chat where chat_id=replyid union select unnest(pingids)) a where account_id<>get_account_id())
     , n as (insert into notification(account_id) select account_id from aa returning *)
    , cn as (insert into chat_notification(notification_id,chat_id) select notification_id,chat_id from n cross join i)
     , a as (update account set account_notification_id = default from n where account.account_id=n.account_id)
     , p as (insert into ping(chat_id,account_id) select chat_id,account_id from aa cross join i)
     , l as (insert into listener(account_id,room_id,listener_latest_read_chat_id)
             select get_account_id(),room_id,chat_id from i natural join room
             on conflict on constraint listener_pkey do update set listener_latest_read_chat_id=excluded.listener_latest_read_chat_id)
     , r as (insert into participant(room_id,account_id)
             select room_id,get_account_id() from i
             on conflict on constraint participant_pkey
                do update set participant_latest_chat_at=default, participant_chat_count=participant.participant_chat_count+1)
  select chat_id from i;
$$;
--
create function change(id integer, msg text) returns void language sql security definer set search_path=db,api,pg_temp as $$
  select _error('chat does not exist') where not exists(select 1 from chat where chat_id=id);
  select _error('message not mine') from chat where chat_id=id and account_id<>get_account_id();
  select _error('too late') from chat where chat_id=id and extract('epoch' from current_timestamp-chat_at)>300;
  select _error(413,'message too long') where length(msg)>5000;
  insert into chat_history(chat_id,chat_history_markdown) values(id,msg);
  --
  with w as (select chat_reply_id from chat natural join (select chat_id chat_reply_id, account_id reply_account_id from chat) z where chat_id=id and chat_reply_id is not null)
  update account set account_notification_id = default where account_id in(select account_id from w);
  --
  update chat set chat_markdown = msg, chat_change_id = default, chat_change_at = default where chat_id=id;
$$;
create function change(id integer, msg text, replyid integer, pingids integer[]) returns void language sql security definer set search_path=db,api,pg_temp as $$
  select _error('chat does not exist') where not exists(select 1 from chat where chat_id=id);
  select _error('message not mine') from chat where chat_id=id and account_id<>get_account_id();
  select _error('you cannot edit a message that is already a reply to be be a reply to a different message') from chat where chat_id=id and chat_reply_id is not null and chat_reply_id<>replyid;
  select _error('too late') from chat where chat_id=id and extract('epoch' from current_timestamp-chat_at)>300;
  select _error(413,'message too long') where length(msg)>5000;
  --
  with d as (update notification set notification_dismissed_at = current_timestamp where notification_id in(select notification_id from notification natural join chat_notification where chat_id=replyid and account_id=get_account_id()) returning *)
  update account set account_notification_id = default from d where account.account_id=d.account_id;
  --
  update chat set chat_markdown = msg, chat_reply_id=replyid, chat_change_id = default, chat_change_at = default where chat_id=id;
  --
  with h as (insert into chat_history(chat_id,chat_history_markdown) values(id,msg))
    , aa as (select account_id
             from (select account_id from chat where chat_id=replyid union select unnest(pingids)) a
             where account_id<>get_account_id() and not exists (select 1 from chat_notification natural join notification where chat_id=id and account_id=a.account_id))
     , n as (insert into notification(account_id) select account_id from aa returning *)
    , cn as (insert into chat_notification(notification_id,chat_id) select notification_id,id from n)
     , a as (update account set account_notification_id = default from n where account.account_id=n.account_id)
     , p as (insert into ping(chat_id,account_id) select id,account_id from aa on conflict do nothing)
  select 1;
  --
  with w as (select chat_reply_id from chat natural join (select chat_id chat_reply_id, account_id reply_account_id from chat) z where chat_id=id and chat_reply_id is not null)
  update account set account_notification_id = default where account_id in(select account_id from w);
$$;
--
create function flag(id bigint, direction integer) returns bigint language sql security definer set search_path=db,api,pg_temp as $$
  select _error('cant flag own message') where exists(select 1 from chat where chat_id=id and account_id=get_account_id());
  select _error('access denied') where get_account_id() is null;
  select _error('invalid chat') where not exists (select 1 from _chat where chat_id=id);
  select _error('invalid flag direction') where direction not in(-1,0,1);
  select _error(429,'rate limit') where (select count(1) from chat_flag_history where account_id=get_account_id() and chat_flag_history_at>current_timestamp-'1m'::interval)>6;
  --
  select _ensure_communicant(get_account_id(),get_community_id());
  --
  with d as (delete from chat_flag where chat_id=id and account_id=get_account_id() returning *)
     , q as (update chat set chat_active_flags = chat_active_flags-abs(d.chat_flag_direction)
                           , chat_flags = chat_flags-(case when d.chat_flag_is_crew then 0 else d.chat_flag_direction end)
                           , chat_crew_flags = chat_crew_flags-(case when d.chat_flag_is_crew then d.chat_flag_direction else 0 end)
             from d
             where chat.chat_id=d.chat_id)
  select null;
  --
  with i as (insert into chat_flag(chat_id,account_id,chat_flag_direction,chat_flag_is_crew)
             select id,account_id,direction,communicant_is_post_flag_crew
             from db.communicant
             where account_id=get_account_id() and community_id=get_community_id()
             returning *)
     , u as (update chat set chat_active_flags = chat_active_flags+abs(i.chat_flag_direction)
                           , chat_flags = chat_flags+(case when i.chat_flag_is_crew then 0 else i.chat_flag_direction end)
                           , chat_crew_flags = chat_crew_flags+(case when i.chat_flag_is_crew then i.chat_flag_direction else 0 end)
                           , chat_change_id = default
             from i
             where chat.chat_id=i.chat_id
             returning chat_change_id)
     , h as (insert into chat_flag_history(chat_id,account_id,chat_flag_history_direction,chat_flag_history_is_crew)
             select chat_id,account_id,chat_flag_direction,chat_flag_is_crew from i
             returning chat_flag_history_id,chat_flag_history_direction)
/*    , nn as (select chat_flag_history_id,account_id
             from h cross join (select account_id from communicant where community_id=get_community_id() and communicant_is_post_flag_crew and account_id<>get_account_id()) c
             where chat_flag_history_direction>0)
     , n as (insert into notification(account_id) select account_id from nn returning *)
   , qfn as (insert into chat_flag_notification(notification_id,chat_flag_history_id) select notification_id,chat_flag_history_id from nn natural join n)*/
     , l as (insert into listener(account_id,room_id,listener_latest_read_chat_id)
             select get_account_id(),get_room_id(),max(chat_id) from chat where room_id=get_room_id()
             on conflict on constraint listener_pkey do update set listener_latest_read_chat_id=excluded.listener_latest_read_chat_id)
--  update account set account_notification_id = default where account_id in (select account_id from n);
  select chat_change_id from u;
$$;
--
create function set_star(cid bigint) returns bigint language sql security definer set search_path=db,api,pg_temp as $$
  select _error('cant star own message') where exists(select 1 from chat where chat_id=cid and account_id=get_account_id());
  select _error('already starred') where exists(select 1 from chat_star where chat_id=cid and account_id=get_account_id());
  select _error('access denied') where not exists(select 1 from api._room where room_id=get_room_id() and room_can_chat);
  insert into chat_star(chat_id,account_id,room_id) select chat_id,get_account_id(),room_id from chat where chat_id=cid;
  update chat set chat_change_id = default where chat_id=cid returning chat_change_id;
$$;
--
create function remove_star(cid bigint) returns bigint language sql security definer set search_path=db,api,pg_temp as $$
  select _error('not already starred') where not exists(select 1 from chat_star where chat_id=cid and account_id=get_account_id());
  select _error('access denied') where not exists(select 1 from api._room where room_id=get_room_id() and room_can_chat);
  delete from chat_star where chat_id=cid and account_id=get_account_id();
  update chat set chat_change_id = default where chat_id=cid returning chat_change_id;
$$;
--
create function read(ids integer[]) returns void language sql security definer set search_path=db,api,pg_temp as $$
  select _error('access denied') where get_account_id() is null;
  --
  with w as (select room_id, max(chat_id) chat_id
             from chat natural join (select room_id,listener_latest_read_chat_id from listener where account_id=get_account_id()) x
             where chat_id in (select * from unnest(ids)) and chat_id>coalesce(listener_latest_read_chat_id,0)
             group by room_id)
  update listener l
  set listener_latest_read_chat_id = w.chat_id
  from w
  where w.room_id=l.room_id and account_id=get_account_id();
$$;
--
--
revoke all on all functions in schema chat from public;
do $$
begin
  execute (select string_agg('grant select on '||viewname||' to post;', E'\n') from pg_views where schemaname='chat' and viewname!~'^_');
  execute ( select string_agg('grant execute on function '||p.oid::regproc||'('||pg_get_function_identity_arguments(p.oid)||') to post;', E'\n')
            from pg_proc p join pg_namespace n on p.pronamespace=n.oid
            where n.nspname='chat' and proname!~'^_' );
end$$;

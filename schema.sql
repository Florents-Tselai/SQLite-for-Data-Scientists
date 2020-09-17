create table if not exists search_results
(
    data json
);

create table if not exists items
(
    title      text,
    points     int,
    item_id    text primary key,
    item_url   text,
    created_at timestamp
);

drop view if exists hn_items_export;
create view hn_items_export as
select json_extract(hit.value, '$.created_at')           as created_at,
       json_extract(hit.value, '$.objectID')             as objectID,
       json_extract(hit.value, '$.author')               as author,
       json_extract(hit.value, '$.points')               as points,
       json_extract(hit.value, '$.comment_text')         as comment_text,
       length(json_extract(hit.value, '$.comment_text')) as comment_text_length,
       json_extract(hit.value, '$.story_text')           as story_text,
       length(json_extract(hit.value, '$.story_text'))   as story_text_length,
       json_extract(hit.value, '$.story_id')             as story_id,
       json_extract(hit.value, '$.story_title')          as story_title,
       json_extract(hit.value, '$.story_url')            as story_url,
       json_extract(hit.value, '$.parent_id')            as parent_id,
       json_extract(hit.value, '$.relevancy_score')      as relevancy_score,
       json_extract(hit.value, '$._tags')                as tags
from search_results,
     json_each(data, '$.hits') as hit
order by created_at desc;

drop trigger if exists unpack_search_results;

drop trigger if exists unpack_search_results;

create trigger if not exists unpack_search_results
    after
insert
on search_results
    for each row
begin
insert into items
values (json_extract(new.data, '$.title'), json_extract(new.data, '$.points'), json_extract(new.data, '$.objectID'),
        "https://news.ycombinator.com/item?id=" || json_extract(new.data, '$.objectID'),
        json_extract(new.data, '$.created_at'))
on conflict do nothing;
end


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


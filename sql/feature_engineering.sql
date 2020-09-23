create view tweets_with_features as
with text_related_features as (
    select tweet_id,
           length(text)                                               as tweet_length,
           like(lower(text), '%a%')                                   as has_sucks_string,
           lower(text) like '%amazing%' or lower(text) like '%great%' as has_positive_word
    from tweets
),
     time_related_features as (
         select tweet_id,
                strftime('%Y', datetime(replace(tweet_created, ' -0800', ''))) AS tweet_year,
                strftime('%H', datetime(replace(tweet_created, ' -0800', ''))) AS tweet_hour
         from tweets
     ),

     airline_freq_aggregates as (
         select airline,
                count(*)                                                       as total_tweets_for_airline,
                round(avg(length(text)), 0)                                    as avg_tweet_length_for_airline,
                strftime('%H', datetime(replace(tweet_created, ' -0800', ''))) as tweet_hour
         from tweets
         group by airline
     ),

     count_by_airline_and_hour as (
         select airline,
                strftime('%H', datetime(replace(tweet_created, ' -0800', ''))) as tweet_hour,
                count(*)                                                       as count_tweets_for_airline_in_hour
         from tweets
         group by airline, tweet_hour
     ),

     count_by_airline_and_sentiment as (
         select airline,
                airline_sentiment,
                count(*) as count_sentiment_tweets_for_airlines
         from tweets
         group by airline, airline_sentiment
     )

select *
from text_related_features
         inner join time_related_features using (tweet_id)
         inner join tweets using (tweet_id)
         inner join airline_freq_aggregates using (airline)
         inner join count_by_airline_and_hour a on tweets.airline = a.airline and time_related_features.tweet_hour =
                                                                                  a.tweet_hour
         inner join count_by_airline_and_sentiment b
                    on tweets.airline = b.airline and tweets.airline_sentiment = b.airline_sentiment;

create table materialized_text_related_features as
select *
from tweets_with_features


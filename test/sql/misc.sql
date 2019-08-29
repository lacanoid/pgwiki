\pset null _null_

SET client_min_messages = warning;
SET ROLE postgres;

select wiki.page_set('Main_Page','Hello! :)');
select wiki.page_set('rss','<rss></rss>'::xml);
select wiki.page_set('talk:Main_Page','<li>Bla bla</li>'::xml);
select wiki.page_set('Sandbox','More text here');
select wiki.page_set('talk:Sandbox','{"aha":5}'::json);

select page_title,
       page_body,
       page_regtype,
       page_vector
  from wiki.page;

select rev_comment,rev_length
  from wiki.revision;



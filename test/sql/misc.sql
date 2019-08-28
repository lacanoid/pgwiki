\pset null _null_

SET client_min_messages = warning;
SET ROLE postgres;

select wiki.page_set('Main_Page','Hello! :)');

select page_title,
       page_body,
       page_regtype,
       page_vector
  from wiki.page;

select rev_comment,rev_length
  from wiki.revision;



--
-- PostgreSQL database dump
--

-- Dumped from database version 10.9 (Debian 10.9-1.pgdg80+1)
-- Dumped by pg_dump version 10.9 (Debian 10.9-1.pgdg80+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
--SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: SCHEMA wiki; Type: COMMENT; Schema: -; Owner: wiki
--

COMMENT ON SCHEMA wiki IS 'Ljudmila InterWiki';
GRANT USAGE ON SCHEMA wiki TO public;

--
-- Name: content_type; Type: DOMAIN; Schema: wiki; Owner: wiki
--

CREATE DOMAIN wiki.content_type AS text NOT NULL;


ALTER DOMAIN wiki.content_type OWNER TO wiki;

--
-- Name: id; Type: DOMAIN; Schema: wiki; Owner: wiki
--

CREATE DOMAIN wiki.id AS integer;


ALTER DOMAIN wiki.id OWNER TO wiki;

--
-- Name: link_reftype; Type: TYPE; Schema: wiki; Owner: wiki
--

CREATE TYPE wiki.link_reftype AS ENUM (
    'href',
    'src'
);


ALTER TYPE wiki.link_reftype OWNER TO wiki;

--
-- Name: namespace; Type: TYPE; Schema: wiki; Owner: wiki
--

CREATE TYPE wiki.namespace AS ENUM (
    'main',
    'talk',
    'user',
    'project',
    'file',
    'message',
    'template',
    'help',
    'category',
    'property',
    'image',
    'special'
);


ALTER TYPE wiki.namespace OWNER TO wiki;

--
-- Name: nid; Type: DOMAIN; Schema: wiki; Owner: wiki
--

CREATE DOMAIN wiki.nid AS bigint;


ALTER DOMAIN wiki.nid OWNER TO wiki;

--
-- Name: result; Type: DOMAIN; Schema: wiki; Owner: wiki
--

CREATE DOMAIN wiki.result AS xml;


ALTER DOMAIN wiki.result OWNER TO wiki;

--
-- Name: url; Type: DOMAIN; Schema: wiki; Owner: wiki
--

CREATE DOMAIN wiki.url AS text;


ALTER DOMAIN wiki.url OWNER TO wiki;

--
-- Name: wiki_type; Type: DOMAIN; Schema: wiki; Owner: wiki
--

CREATE DOMAIN wiki.wiki_type AS text;


ALTER DOMAIN wiki.wiki_type OWNER TO wiki;

--
-- Name: foreign_page_get(text, text); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.foreign_page_get(wiki text, title text) RETURNS text
    LANGUAGE plperlu
    AS $_$my ($wiki,$title)=@_;

use MediaWiki::API;

my $plan = spi_prepare('SELECT * FROM wiki.wiki($1)', 'text');
my $wiki = spi_exec_prepared($plan,$wiki)->{rows}->[0];

my $mw = MediaWiki::API->new();
$mw->{config}->{api_url} = $wiki->{wiki_url}."/api.php";

# log in to the wiki
if($wiki->{wiki_username}) {
$mw->login( { lgname => $wiki->{wiki_username}, lgpassword => $wiki->{wiki_password} } )
 || elog(ERROR,"LOGIN:" . $mw->{error}->{code} . ': ' . $mw->{error}->{details});
}

my $page = $mw->get_page( { title => $title });

if($wiki->{wiki_username}) {
 $mw->logout();
}

if($page->{missing}) { 
 return undef; 
}
return $page->{'*'};

$_$;


ALTER FUNCTION wiki.foreign_page_get(wiki text, title text) OWNER TO wiki;

--
-- Name: foreign_pages_search(text, text); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.foreign_pages_search(wiki text, title text) RETURNS SETOF text
    LANGUAGE plperlu
    AS $_X$my ($wiki,$search)=@_;

use MediaWiki::API;

my $plan = spi_prepare('SELECT * FROM wiki.wiki($1)', 'text');
my $wiki = spi_exec_prepared($plan,$wiki)->{rows}->[0];

my $mw = MediaWiki::API->new();
$mw->{config}->{api_url} = $wiki->{wiki_url}."/api.php";

# log in to the wiki
if($wiki->{wiki_username}) {
$mw->login( { lgname => $wiki->{wiki_username}, lgpassword => $wiki->{wiki_password} } )
 || elog(ERROR,"LOGIN: " . $mw->{error}->{code} . ': ' . $mw->{error}->{details});
}

my $articles = $mw->list ( {
        action => 'query',
        list => 'search',
        srsearch => $search,
                srwhat => 'text',
                srnamespace => join('|',(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 102, 103, 104, 105, 108, 109)),
                srlimit => 'max' } )
        || elog(ERROR, 'LIST: ' . $mw->{error}->{code} . ': ' . $mw->{error}->{details});

foreach (@{$articles}) {
  return_next($_->{title});
}


if($wiki->{wiki_username}) {
 $mw->logout();
}

return undef;

$_X$;


ALTER FUNCTION wiki.foreign_pages_search(wiki text, title text) OWNER TO wiki;

--
-- Name: html_entities(text); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.html_entities(text) RETURNS text
    LANGUAGE plperl IMMUTABLE
    AS $_$
my ($text)=@_;
my $emap =
{ # amp=>38, quot=>34, gt=>62, lt=>60, 
 cent=>162, nbsp=>160, iexcl=>161, pound=>163, curren=>164,
 yen=>165, brvbar=>166, sect=>167, uml=>168, copy=>169, ordf=>170, laquo=>171, not=>172,
 shy=>173, reg=>174, macr=>175, deg=>176, plusmn=>177, sup2=>178, sup3=>179, acute=>180, micro=>181,
 para=>182, middot=>183, cedil=>184, sup1=>185, ordm=>186, raquo=>187, frac14=>188, frac12=>189,
 frac34=>190, iquest=>191, Agrave=>192, Aacute=>193, Acirc=>194, Atilde=>195, Auml=>196, Aring=>197,
 AElig=>198, Ccedil=>199, Egrave=>200, Eacute=>201, Ecirc=>202, Euml=>203, Igrave=>204, Iacute=>205,
 Icirc=>206, Iuml=>207, ETH=>208, Ntilde=>209, Ograve=>210, Oacute=>211, Ocirc=>212, Otilde=>213,
 Ouml=>214, times=>215, Oslash=>216, Ugrave=>217, Uacute=>218, Ucirc=>219, Uuml=>220, Yacute=>221,
 THORN=>222, szlig=>223, agrave=>224, aacute=>225, acirc=>226, atilde=>227, auml=>228, aring=>229, 
 aelig=>230, ccedil=>231, egrave=>232, eacute=>233, ecirc=>234, euml=>235, igrave=>236, iacute=>237,
 icirc=>238, iuml=>239, eth=>240, ntilde=>241, ograve=>242, oacute=>243, ocirc=>244, otilde=>245,
 ouml=>246, divide=>247, oslash=>248, ugrave=>249, uacute=>250, ucirc=>251, uuml=>252, yacute=>253,
 thorn=>254, yuml=>255, fnof=>402, OElig=>338, oelig=>339, Scaron=>352, scaron=>353, Yuml=>376,
 circ=>710, tilde=>732, Alpha=>913, Beta=>914, Gamma=>915, Delta=>916, Epsilon=>917, Zeta=>918,
 Eta=>919, Theta=>920, Iota=>921, Kappa=>922, Lambda=>923, Mu=>924, Nu=>925, Xi=>926, Omicron=>927,
 Pi=>928, Rho=>929, Sigma=>931, Tau=>932, Upsilon=>933, Phi=>934, Chi=>935, Psi=>936, Omega=>937,
 alpha=>945, beta=>946, gamma=>947, delta=>948, epsilon=>949, zeta=>950, eta=>951, theta=>952,
 iota=>953, kappa=>954, lambda=>955, mu=>956, nu=>957, xi=>958, omicron=>959, pi=>960, rho=>961,
 sigmaf=>962, sigma=>963, tau=>964, upsilon=>965, phi=>966, chi=>967, psi=>968, omega=>969,
 thetasym=>977, upsih=>978, piv=>982, ensp=>8194, emsp=>8195, thinsp=>8201, zwnj=>8204, zwj=>8205,
 lrm=>8206, rlm=>8207, bull=>8226, hellip=>8230, ndash=>8211, mdash=>8212, lsquo=>8216, rsquo=>8217,
 sbquo=>8218, ldquo=>8220, rdquo=>8221, bdquo=>8222, dagger=>8224, Dagger=>8225, prime=>8242,
 Prime=>8243, oline=>8254, frasl=>8260, permil=>8240, lsaquo=>8249, rsaquo=>8250, weierp=>8472,
 image=>8465, real=>8476, trade=>8482, alefsym=>8501, larr=>8592, uarr=>8593, rarr=>8594, darr=>8595,
 harr=>8596, crarr=>8629, lArr=>8656, uArr=>8657, rArr=>8658, dArr=>8659, hArr=>8660, forall=>8704,
 part=>8706, exist=>8707, empty=>8709, nabla=>8711, isin=>8712, notin=>8713, ni=>8715, prod=>8719,
 sum=>8721, minus=>8722, lowast=>8727, radic=>8730, prop=>8733, infin=>8734, ang=>8736, and=>8743,
 or=>8744, cap=>8745, cup=>8746, int=>8747, there4=>8756, sim=>8764, cong=>8773, asymp=>8776,
 ne=>8800, equiv=>8801, le=>8804, ge=>8805, sub=>8834, sup=>8835, nsub=>8836, sube=>8838, supe=>8839,
 oplus=>8853, otimes=>8855, perp=>8869, sdot=>8901, lceil=>8968, rceil=>8969, lfloor=>8970,
 rfloor=>8971, lang=>9001, rang=>9002, loz=>9674, spades=>9824, clubs=>9827, hearts=>9829,
 diams=>9830, euro=>8364};

 $text=~s|&([a-zA-Z]\w+);|$emap->{$1}?chr($emap->{$1}):"&$1;"|ge;
# $text=~s|&#(\d+);|$1?chr($1):""|ge;
 return $text;
$_$;


ALTER FUNCTION wiki.html_entities(text) OWNER TO wiki;

--
-- Name: html_tidy(text); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.html_tidy(text) RETURNS xml
    LANGUAGE plperlu IMMUTABLE STRICT COST 200
    AS $_X$
use HTML::Tidy;

my $tidy = HTML::Tidy->new( {
 doctype=>'omit', output_xhtml=>1,
 clean=>1, bare=>1, indent=>1,
 'drop-empty-paras'=>1, 'drop-font-tags'=>1, 'drop-proprietary-attributes'=>1,
 'punctuation-wrap'=>1, 'show-body-only'=>1, 'hide-comments'=>1,
});
$tidy->ignore( type => TIDY_WARNING );
my $xml = $tidy->clean($_[0]);

for my $message ( $tidy->messages ) { elog(NOTICE,$message->as_string); }

return '<html>'.$xml.'</html>';

$_X$;


ALTER FUNCTION wiki.html_tidy(text) OWNER TO wiki;

--
-- Name: is_xml(regtype); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.is_xml(regtype) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
 select $1 = 'xml'::regtype
$_$;


ALTER FUNCTION wiki.is_xml(regtype) OWNER TO wiki;

--
-- Name: nid(); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.nid() RETURNS wiki.nid
    LANGUAGE sql
    AS $$select cast(nextval('wiki.nid_seq') as wiki.nid)$$;


ALTER FUNCTION wiki.nid() OWNER TO wiki;

--
-- Name: nid_body(); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.nid_body() RETURNS wiki.nid
    LANGUAGE sql
    AS $$select cast(nextval('wiki.nid_body_seq') as wiki.nid)$$;


ALTER FUNCTION wiki.nid_body() OWNER TO wiki;

--
-- Name: nid_page(); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.nid_page() RETURNS wiki.nid
    LANGUAGE sql
    AS $$select cast(nextval('wiki.nid_page_seq') as wiki.nid)$$;


ALTER FUNCTION wiki.nid_page() OWNER TO wiki;

--
-- Name: nid_rev(); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.nid_rev() RETURNS wiki.nid
    LANGUAGE sql
    AS $$select cast(nextval('wiki.nid_rev_seq') as wiki.nid)$$;


ALTER FUNCTION wiki.nid_rev() OWNER TO wiki;

--
-- Name: node_before_trigger(); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.node_before_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare
 body_id2 wiki.nid;
 md5 text;
 q text;
 length int;
begin
 -- INSERT and UPDATE
 if tg_op = 'INSERT' or tg_op = 'UPDATE' then
   if new.page_regtype is not null then

   if wiki.is_xml(new.page_regtype) then
     new.page_body := wiki.html_entities(new.page_body);
   end if;
   
   -- check for regtype compatibility
     q := 'SELECT CAST($1 AS '||cast(new.page_regtype as text)||')';
--     raise notice '%',q;
     execute
      'SELECT CAST($1 AS '||cast(new.page_regtype as text)||')'
     using new.page_body;
   end if;

   -- calculate search index
   new.page_vector := to_tsvector(new.page_body);
   md5 := coalesce(md5(new.page_body),'NULL');
  
   if tg_op = 'UPDATE' then
     if new.page_body is not distinct from old.page_body then
       -- no change => no revision
       return new;
     end if;
     length := length(new.page_body) - length(old.page_body);
   end if;
   
   if tg_op = 'INSERT' then
     length := length(new.page_body);
   end if;

   -- look for previous revision of same text, create if not found
   select into body_id2 body_id
     from wiki.revision rev 
     join wiki.body using (body_id)
    where rev.page_id = new.page_id
      and rev.rev_hash = md5
      and body.body_text = new.page_body;
   if not found then
    insert into wiki.body (body_text,body_vector)
    values (new.page_body,new.page_vector)
    returning body_id into body_id2;
   end if;

   -- make new revision
   insert into wiki.revision (
     page_id, body_id, 
     rev_timestamp, rev_user, rev_hash, rev_length)
   values (
     new.page_id, body_id2,
     now(), current_role, md5, length
   )
   returning rev_id into new.rev_id;

   return new;
 end if;

 -- DELETE
 if tg_op = 'DELETE' then
   md5 := coalesce(md5(old.page_body),'NULL');

   -- make new revision
   select into body_id2 body_id
     from wiki.revision rev 
     join wiki.body using (body_id)
    where rev.page_id = old.page_id
      and rev.rev_hash = md5
      and body.body_text = old.page_body;

   insert into wiki.revision (
     page_id, body_id, rev_deleted,
     rev_timestamp, rev_user, rev_hash)
   values (
     new.page_id, body_id2, true,
     now(), current_role, md5
   );
   return old;
 end if;
end
$_$;


ALTER FUNCTION wiki.node_before_trigger() OWNER TO wiki;

--
-- Name: node_links_trigger(); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.node_links_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if wiki.is_xml(new.page_regtype) then
  -- content is of XML type

    if tg_op = 'INSERT' or tg_op = 'UPDATE' then
      perform *
         from wiki.node_links_update(new.page_id,new.page_body::xml);
    end if;
  
    if tg_op = 'DELETE' then
      delete from wiki.links
       where link_from = old.page_id;
    end if;

  end if;
  return null;
end
$$;


ALTER FUNCTION wiki.node_links_trigger() OWNER TO wiki;

--
-- Name: node_links_update(wiki.nid, xml); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.node_links_update(my_page_id wiki.nid, body xml, OUT link_url text, OUT link_reftype wiki.link_reftype, OUT link_action text) RETURNS SETOF record
    LANGUAGE plpgsql COST 500 ROWS 100
    AS $$
declare
 r record;
begin
  for r in
  select * 
    from wiki.page_extract_links(body) le
    full outer join wiki.links ls
    on (ls.link_reftype=le.reftype and ls.link_url=le.url)
  loop
    if r.reftype is null then
    -- no longer linked, delete old link
      delete from wiki.links ls
      where ls.link_from = my_page_id
        and ls.link_reftype = r.reftype
        and ls.link_url = r.url;
      link_action := 'delete';
      link_url := r.link_url;
      link_reftype := r.link_reftype;
    else
      if r.link_from is null then
      -- store new link
        insert into wiki.links (link_from, link_reftype, link_url)
        values (my_page_id, r.reftype, r.url);
        link_action := 'insert';
        link_url := r.url;
        link_reftype := r.reftype;
      else
      -- link already stored
        link_action := 'none';
        link_url := r.url;
        link_reftype := r.reftype;
      end if;
    end if;    
    return next; 
  end loop;
end
$$;


ALTER FUNCTION wiki.node_links_update(my_page_id wiki.nid, body xml, OUT link_url text, OUT link_reftype wiki.link_reftype, OUT link_action text) OWNER TO wiki;

--
-- Name: page_extract_links(xml); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.page_extract_links(body xml, OUT reftype wiki.link_reftype, OUT url text) RETURNS SETOF record
    LANGUAGE sql STABLE STRICT
    AS $$
 select 'href'::wiki.link_reftype as reftype, 
        link::text as url 
   from unnest(xpath('//@href',body)) as link
 union
 select 'src'::wiki.link_reftype  as reftype, 
        link::text as url
   from unnest(xpath('//@src',body)) as link
$$;


ALTER FUNCTION wiki.page_extract_links(body xml, OUT reftype wiki.link_reftype, OUT url text) OWNER TO wiki;

--
-- Name: FUNCTION page_extract_links(body xml, OUT reftype wiki.link_reftype, OUT url text); Type: COMMENT; Schema: wiki; Owner: wiki
--

COMMENT ON FUNCTION wiki.page_extract_links(body xml, OUT reftype wiki.link_reftype, OUT url text) IS 'Extract links from (X)HTML';


--
-- Name: page_get(text); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.page_get(full_title text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
 r record;
 p record;
begin
 r := wiki.title_parse(full_title);
 select into p
        *
   from wiki.page
  where page_title = r.title and page_namespace = r.namespace;
 return p.page_body;
end
$$;


ALTER FUNCTION wiki.page_get(full_title text) OWNER TO wiki;

--
-- Name: page_get(wiki.nid); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.page_get(my_page_id wiki.nid) RETURNS text
    LANGUAGE plpgsql
    AS $_$
declare
 r record;
 p record;
begin
 select into p
        *
   from wiki.page
  where page_id = $1;
 return p.page_body;
end
$_$;


ALTER FUNCTION wiki.page_get(my_page_id wiki.nid) OWNER TO wiki;

--
-- Name: page_get(text, wiki.nid); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.page_get(full_title text, my_rev_id wiki.nid) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
 t record;
 p record;
begin
 t := wiki.title_parse(full_title);
 if my_rev_id is null then
 -- current revision
  select into p
         page_id,
         page_body,
         page_mimetype
    from wiki.page n
   where n.page_title = t.title and n.page_namespace = t.namespace;
 else
 -- old revision
  select into p
         n.page_id,
         b.body_text as page_body,
         n.page_mimetype
    from wiki.revision r 
    join wiki.node n using (page_id)
    join wiki.body b using (body_id)
   where n.page_title = t.title and n.page_namespace = t.namespace
     and r.rev_id = my_rev_id;
 end if;

 return p.page_body;
end
$$;


ALTER FUNCTION wiki.page_get(full_title text, my_rev_id wiki.nid) OWNER TO wiki;

--
-- Name: page_get_data(text); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.page_get_data(full_title text) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare
 r record;
 j json;
begin
 r := wiki.title_parse(full_title);
 select into j
        row_to_json(p)
   from wiki.page p
  where page_title = r.title and page_namespace = r.namespace;
 return j;
end
$$;


ALTER FUNCTION wiki.page_get_data(full_title text) OWNER TO wiki;

--
-- Name: page_get_data(text, wiki.nid); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.page_get_data(full_title text, my_rev_id wiki.nid) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare
 t record;
 p record;
 j json;
begin
 t := wiki.title_parse(full_title);
 if my_rev_id is null then
 -- current revision
  select into p
         *
    from wiki.page n
   where n.page_title = t.title and n.page_namespace = t.namespace;
 else
 -- old revision
  select into p
         n.page_id,
         b.body_text as page_body,
         n.page_mimetype,
         r.rev_id,
         r.rev_timestamp,
         r.rev_user,
         r.rev_comment
    from wiki.revision r 
    join wiki.node n on (n.page_id=r.page_id)
    join wiki.body b on (r.body_id=b.body_id)
   where n.page_title = t.title and n.page_namespace = t.namespace
     and r.rev_id = my_rev_id;
 end if;

 return row_to_json(p);
end
$$;


ALTER FUNCTION wiki.page_get_data(full_title text, my_rev_id wiki.nid) OWNER TO wiki;

--
-- Name: page_set(text, json); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.page_set(full_title text, new_body json) RETURNS wiki.nid
    LANGUAGE plpgsql STRICT
    AS $$
declare
 r record;
 new_rev_id wiki.nid;
begin
 r := wiki.title_parse(full_title);
 update wiki.node
    set page_body = new_body,
        page_regtype = 'json'::regtype
  where page_title = r.title and page_namespace = r.namespace
 returning rev_id into new_rev_id;
 if not found then
   insert into wiki.node (page_namespace, page_title, page_body, page_regtype)
          values (r.namespace, r.title, new_body, 'json'::regtype)
   returning rev_id into new_rev_id;
   return new_rev_id;
 end if;
 return new_rev_id;
end
$$;


ALTER FUNCTION wiki.page_set(full_title text, new_body json) OWNER TO wiki;

--
-- Name: page_set(text, text); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.page_set(full_title text, new_body text) RETURNS wiki.nid
    LANGUAGE plpgsql STRICT
    AS $$
declare
 r record;
 new_rev_id wiki.nid;
begin
 r := wiki.title_parse(full_title);
 update wiki.node
    set page_body = new_body
  where page_title = r.title and page_namespace = r.namespace
 returning rev_id into new_rev_id;
 if not found then
   insert into wiki.node (page_namespace, page_title, page_body)
          values (r.namespace, r.title, new_body)
   returning rev_id into new_rev_id;
   return new_rev_id;
 end if;
 return new_rev_id;
end
$$;


ALTER FUNCTION wiki.page_set(full_title text, new_body text) OWNER TO wiki;

--
-- Name: page_set(text, xml); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.page_set(full_title text, new_body xml) RETURNS wiki.nid
    LANGUAGE plpgsql STRICT
    AS $$
declare
 r record;
 new_rev_id wiki.nid;
begin
 r := wiki.title_parse(full_title);
 update wiki.node
    set page_body = new_body,
        page_regtype = 'xml'::regtype
  where page_title = r.title and page_namespace = r.namespace
 returning rev_id into new_rev_id;
 if not found then
   insert into wiki.node (page_namespace, page_title, page_body, page_regtype)
          values (r.namespace, r.title, new_body, 'xml'::regtype)
   returning rev_id into new_rev_id;
   return new_rev_id;
 end if;
 return new_rev_id;
end
$$;


ALTER FUNCTION wiki.page_set(full_title text, new_body xml) OWNER TO wiki;

--
-- Name: page_set_with_options(text, text, json); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.page_set_with_options(full_title text, new_body text, mysession json) RETURNS wiki.nid
    LANGUAGE plpgsql STRICT
    AS $$
declare
 r record;
 new_rev_id wiki.nid;
begin
 new_rev_id := wiki.page_set(full_title, new_body);
 update wiki.revision
    set rev_user = coalesce(mysession->>'remote_ip',rev_user)
  where rev_id = new_rev_id;
 return new_rev_id;
end
$$;


ALTER FUNCTION wiki.page_set_with_options(full_title text, new_body text, mysession json) OWNER TO wiki;

--
-- Name: proc_get_info(text); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.proc_get_info(proc_name text, OUT proc_oid oid, OUT sql_identifier text, OUT argnames text[], OUT argtypes text[], OUT comment text, OUT has_http_acl boolean) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
declare 
 p  record;
 pa record;
 r  record;
begin
 begin
   proc_oid := regproc(proc_name)::oid;
   sql_identifier := regproc(proc_oid)::text;
 exception when others then
   return;
 end;
 
 select * 
   from pg_proc
  where pg_proc.oid = proc_oid	
   into p;
   
 select array_agg(p.proargnames[i]) as iproargnames
 from (
   select i, p.proargmodes[i] as mode
     from generate_series(1,array_length(p.proargmodes,1)) i
    where p.proargmodes[i] in ('i','b')
 ) as pam 
 into pa;
 argnames := pa.iproargnames;

 select array_agg(typ)
 from ( 
   select at::regtype::text as typ
     from unnest(p.proargtypes) as at
 ) as at1 
 into argtypes;

 select exists (
   select a
    from unnest(p.proacl) as a
   where a::text like 'http=%X%/%'
 ) into has_http_acl;

 comment := obj_description(proc_oid);

 return next;
end
$$;


ALTER FUNCTION wiki.proc_get_info(proc_name text, OUT proc_oid oid, OUT sql_identifier text, OUT argnames text[], OUT argtypes text[], OUT comment text, OUT has_http_acl boolean) OWNER TO wiki;

--
-- Name: FUNCTION proc_get_info(proc_name text, OUT proc_oid oid, OUT sql_identifier text, OUT argnames text[], OUT argtypes text[], OUT comment text, OUT has_http_acl boolean); Type: COMMENT; Schema: wiki; Owner: wiki
--

COMMENT ON FUNCTION wiki.proc_get_info(proc_name text, OUT proc_oid oid, OUT sql_identifier text, OUT argnames text[], OUT argtypes text[], OUT comment text, OUT has_http_acl boolean) IS 'Inquire about a function';


--
-- Name: special_all_pages(); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.special_all_pages(OUT content xml) RETURNS SETOF xml
    LANGUAGE sql
    AS $$
with a as (
select 
        upper(substr(page_title,1,1)) as g,
	xmlelement(name div, xmlattributes('revision' as class),
	xmlelement(name a, xmlattributes('/'||page_namespace||':'||page_title as href), page_title), '; ',
	to_char(rev_timestamp,'YYYY-MM-DD HH24:MI:SS '), ' .. ',
	xmlelement(name a, xmlattributes('/user:'||rev_user as href), coalesce(rev_user,'?')), '; ',
	'('||coalesce(rev_comment||'')||')'
       ) as content,
       page_title
 from wiki.page
)
select 
  xmlelement(name div, xmlattributes('group' as class),
             xmlelement(name h3, g),
             xmlagg(content order by page_title) 
            ) from a
group by g
order by g 
$$;


ALTER FUNCTION wiki.special_all_pages(OUT content xml) OWNER TO wiki;

--
-- Name: special_new_pages(); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.special_new_pages(OUT content xml) RETURNS SETOF xml
    LANGUAGE sql
    AS $$
with a as (
select 
        date(rev_timestamp),
	xmlelement(name div, xmlattributes('revision' as class),
	xmlelement(name a, xmlattributes('/'||page_namespace||':'||page_title as href), page_namespace||':'||page_title), '; ',
	to_char(rev_timestamp,'HH24:MI '), ' .. ',
	xmlelement(name a, xmlattributes('/user:'||rev_user as href), coalesce(rev_user,'?')), '; ',
	'('||coalesce(rev_comment||'')||')'
       ) as content
 from wiki.page
 order by rev_timestamp desc
 limit 1000
)
select 
  xmlelement(name div, xmlattributes('day' as class),
             xmlelement(name h3, date),
             xmlagg(content)
            )from a
group by date
order by date desc
$$;


ALTER FUNCTION wiki.special_new_pages(OUT content xml) OWNER TO wiki;

--
-- Name: special_recent_changes(); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.special_recent_changes(OUT content xml) RETURNS SETOF xml
    LANGUAGE sql
    AS $$
with a as (
select 
        date(rev_timestamp),
	xmlelement(name div, xmlattributes('revision' as class),
	xmlelement(name a, xmlattributes('/'||page_namespace||':'||page_title||'?rev_id='||r.rev_id as href), page_namespace||':'||page_title), '; ',
	to_char(rev_timestamp,'HH24:MI '), ' .. ',
        xmlelement(name span, 
         '(' || 
         cast(case 
	   when rev_length < 0  then text(rev_length)
	   when rev_length >= 0 then '+'||text(rev_length)
	  end as text)|| ')'
	 ) , ' .. ',
	xmlelement(name a, xmlattributes('/user:'||rev_user as href), coalesce(rev_user,'?')), '; ',
	'('||coalesce(rev_comment||'')||')'
       ) as content
 from wiki.revision r join wiki.node n using (page_id)
 order by rev_timestamp desc
 limit 1000
)
select 
  xmlelement(name div, xmlattributes('group' as class),
             xmlelement(name h3, date),
             xmlagg(content)
            )from a
group by date
order by date desc
$$;


ALTER FUNCTION wiki.special_recent_changes(OUT content xml) OWNER TO wiki;

--
-- Name: title_parse(text); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.title_parse(full_title text, OUT namespace wiki.namespace, OUT title text) RETURNS record
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
declare
 r record;
 m text[];
begin
 full_title := trim(both from full_title);
 m := regexp_matches(full_title,'^(\w+):(.+)$');
 if m is not null then
  namespace := lower(m[1])::wiki.namespace;
  title := m[2];
 else
  namespace := 'main'::wiki.namespace;
  title := full_title;
 end if;
 return;
end
$_$;


ALTER FUNCTION wiki.title_parse(full_title text, OUT namespace wiki.namespace, OUT title text) OWNER TO wiki;

--
-- Name: wiki_id(); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.wiki_id() RETURNS wiki.id
    LANGUAGE sql
    SET search_path TO 'wiki'
    AS $$select nextval('wiki.wiki_seq')::wiki.id$$;


ALTER FUNCTION wiki.wiki_id() OWNER TO wiki;

SET default_tablespace = '';

SET default_with_oids = false;


--
-- Name: wiki; Type: TABLE; Schema: wiki; Owner: wiki
--

CREATE TABLE wiki.wiki (
    wiki_id wiki.id DEFAULT wiki.wiki_id() NOT NULL,
    wiki_name text NOT NULL,
    wiki_type wiki.wiki_type DEFAULT 'mediawiki'::text,
    wiki_version text,
    wiki_url wiki.url NOT NULL,
    wiki_username text,
    wiki_password text,
    wiki_api wiki.url,
    wiki_upload wiki.url
);


ALTER TABLE wiki.wiki OWNER TO wiki;

--
-- Name: wiki(text); Type: FUNCTION; Schema: wiki; Owner: wiki
--

CREATE FUNCTION wiki.wiki(name text) RETURNS wiki.wiki
    LANGUAGE sql
    AS $_$select * from wiki.wiki where wiki_name=$1$_$;


ALTER FUNCTION wiki.wiki(name text) OWNER TO wiki;

--
-- Name: body; Type: TABLE; Schema: wiki; Owner: wiki
--

CREATE TABLE wiki.body (
    body_id wiki.nid DEFAULT wiki.nid_body() NOT NULL,
    body_text text,
    body_vector tsvector
);


ALTER TABLE wiki.body OWNER TO wiki;

--
-- Name: TABLE body; Type: COMMENT; Schema: wiki; Owner: wiki
--

COMMENT ON TABLE wiki.body IS 'Node text bodies and their search vectors';


--
-- Name: links; Type: TABLE; Schema: wiki; Owner: wiki
--

CREATE TABLE wiki.links (
    link_from wiki.nid NOT NULL,
    link_to wiki.nid,
    link_reftype wiki.link_reftype NOT NULL,
    link_url wiki.url NOT NULL
);


ALTER TABLE wiki.links OWNER TO wiki;

--
-- Name: nid_body_seq; Type: SEQUENCE; Schema: wiki; Owner: wiki
--

CREATE SEQUENCE wiki.nid_body_seq
    START WITH 15
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wiki.nid_body_seq OWNER TO wiki;

--
-- Name: nid_page_seq; Type: SEQUENCE; Schema: wiki; Owner: wiki
--

CREATE SEQUENCE wiki.nid_page_seq
    START WITH 15
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wiki.nid_page_seq OWNER TO wiki;

--
-- Name: nid_rev_seq; Type: SEQUENCE; Schema: wiki; Owner: wiki
--

CREATE SEQUENCE wiki.nid_rev_seq
    START WITH 15
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wiki.nid_rev_seq OWNER TO wiki;

--
-- Name: nid_seq; Type: SEQUENCE; Schema: wiki; Owner: wiki
--

CREATE SEQUENCE wiki.nid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wiki.nid_seq OWNER TO wiki;

--
-- Name: node; Type: TABLE; Schema: wiki; Owner: wiki
--

CREATE TABLE wiki.node (
    page_id wiki.nid DEFAULT wiki.nid_page() NOT NULL,
    page_namespace wiki.namespace DEFAULT 'main'::wiki.namespace NOT NULL,
    page_regtype regtype,
    page_title text NOT NULL,
    page_body text,
    page_vector tsvector,
    rev_id wiki.nid,
    page_mimetype text
);


ALTER TABLE wiki.node OWNER TO wiki;

--
-- Name: revision; Type: TABLE; Schema: wiki; Owner: wiki
--

CREATE TABLE wiki.revision (
    rev_id wiki.nid DEFAULT wiki.nid_rev() NOT NULL,
    page_id wiki.nid NOT NULL,
    body_id wiki.nid NOT NULL,
    rev_timestamp timestamp with time zone DEFAULT now() NOT NULL,
    rev_user text,
    rev_comment text,
    rev_minor_edit boolean DEFAULT true NOT NULL,
    rev_deleted boolean DEFAULT false NOT NULL,
    rev_hash text NOT NULL,
    rev_length integer
);


ALTER TABLE wiki.revision OWNER TO wiki;

--
-- Name: page; Type: VIEW; Schema: wiki; Owner: wiki
--

CREATE VIEW wiki.page AS
 SELECT n.rev_id,
    n.page_id,
    n.page_namespace,
    n.page_regtype,
    n.page_title,
    n.page_body,
    n.page_mimetype,
    n.page_vector,
    r.body_id,
    r.rev_timestamp,
    r.rev_user,
    r.rev_comment,
    r.rev_minor_edit,
    r.rev_deleted,
    r.rev_hash,
    r.rev_length AS rev_len
   FROM (wiki.node n
     JOIN wiki.revision r USING (rev_id, page_id));


ALTER TABLE wiki.page OWNER TO wiki;

--
-- Name: wiki_seq; Type: SEQUENCE; Schema: wiki; Owner: wiki
--

CREATE SEQUENCE wiki.wiki_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wiki.wiki_seq OWNER TO wiki;

--
-- Name: body body_pkey; Type: CONSTRAINT; Schema: wiki; Owner: wiki
--

ALTER TABLE ONLY wiki.body
    ADD CONSTRAINT body_pkey PRIMARY KEY (body_id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: wiki; Owner: wiki
--

ALTER TABLE ONLY wiki.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (link_from, link_reftype, link_url);


--
-- Name: node page_page_namespace_page_title_key; Type: CONSTRAINT; Schema: wiki; Owner: wiki
--

ALTER TABLE ONLY wiki.node
    ADD CONSTRAINT page_page_namespace_page_title_key UNIQUE (page_namespace, page_title);


--
-- Name: node page_pkey; Type: CONSTRAINT; Schema: wiki; Owner: wiki
--

ALTER TABLE ONLY wiki.node
    ADD CONSTRAINT page_pkey PRIMARY KEY (page_id);


--
-- Name: revision revision_pkey; Type: CONSTRAINT; Schema: wiki; Owner: wiki
--

ALTER TABLE ONLY wiki.revision
    ADD CONSTRAINT revision_pkey PRIMARY KEY (rev_id);


--
-- Name: wiki wikis_pkey; Type: CONSTRAINT; Schema: wiki; Owner: wiki
--

ALTER TABLE ONLY wiki.wiki
    ADD CONSTRAINT wikis_pkey PRIMARY KEY (wiki_id);


--
-- Name: wiki wikis_wiki_name_key; Type: CONSTRAINT; Schema: wiki; Owner: wiki
--

ALTER TABLE ONLY wiki.wiki
    ADD CONSTRAINT wikis_wiki_name_key UNIQUE (wiki_name);


--
-- Name: node page_biud; Type: TRIGGER; Schema: wiki; Owner: wiki
--

CREATE TRIGGER page_biud BEFORE INSERT OR DELETE OR UPDATE ON wiki.node FOR EACH ROW EXECUTE PROCEDURE wiki.node_before_trigger();


--
-- Name: node page_links_ai; Type: TRIGGER; Schema: wiki; Owner: wiki
--

CREATE TRIGGER page_links_ai AFTER INSERT ON wiki.node FOR EACH ROW WHEN (wiki.is_xml(new.page_regtype)) EXECUTE PROCEDURE wiki.node_links_trigger();


--
-- Name: node page_links_au; Type: TRIGGER; Schema: wiki; Owner: wiki
--

CREATE TRIGGER page_links_au AFTER UPDATE ON wiki.node FOR EACH ROW WHEN ((wiki.is_xml(new.page_regtype) AND (old.* IS DISTINCT FROM new.*))) EXECUTE PROCEDURE wiki.node_links_trigger();


--
-- Name: links links_link_from_fkey; Type: FK CONSTRAINT; Schema: wiki; Owner: wiki
--

ALTER TABLE ONLY wiki.links
    ADD CONSTRAINT links_link_from_fkey FOREIGN KEY (link_from) REFERENCES wiki.node(page_id);


--
-- Name: links links_link_to_fkey; Type: FK CONSTRAINT; Schema: wiki; Owner: wiki
--

ALTER TABLE ONLY wiki.links
    ADD CONSTRAINT links_link_to_fkey FOREIGN KEY (link_to) REFERENCES wiki.node(page_id);


--
-- Name: node page_rev_id_fkey; Type: FK CONSTRAINT; Schema: wiki; Owner: wiki
--

ALTER TABLE ONLY wiki.node
    ADD CONSTRAINT page_rev_id_fkey FOREIGN KEY (rev_id) REFERENCES wiki.revision(rev_id);


--
-- Name: revision revision_body_id_fkey; Type: FK CONSTRAINT; Schema: wiki; Owner: wiki
--

ALTER TABLE ONLY wiki.revision
    ADD CONSTRAINT revision_body_id_fkey FOREIGN KEY (body_id) REFERENCES wiki.body(body_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: revision revision_page_id_fkey; Type: FK CONSTRAINT; Schema: wiki; Owner: wiki
--

ALTER TABLE ONLY wiki.revision
    ADD CONSTRAINT revision_page_id_fkey FOREIGN KEY (page_id) REFERENCES wiki.node(page_id) DEFERRABLE INITIALLY DEFERRED;



--Upper or Lower key words
UPDATE foo SET bar = x; --?
update foo set bar = x; --?
SELECT * FROM foo; --?
select * from foo; --?


-- Identifiers
update foo set bar = x; --?
update "foo" set "bar" = x; --?

-- Concatenation
select 'foo'
'bar'; --?
select 'foo' || 'bar'; --?
select 'foobar'; --?

--Positional Parameters
create function foo(text) returns text as $$ select $1 $$ language SQL; --?
create function foo(in_text text) returns text as $$ select in_text $$ language sql; --?

--Arrays
select ARRAY[1,2,3+4]; --bad
select array[1, 2, 3 + 4]; --good

--Using of Case word key (division-by-zero example)
select * from foo where bar > 0 and baz/bar > 1; --error
select case when min(bar) > 0 then avg(baz/bar) end from foo;
--error: aggregates are computed concurrently over all the input rows.
select * from foo where case when bar > 0 then baz/bar > 1 end; --good

-- Potitional Notations
-- create function foo(a, b, c) returns type as $$ select a, b, c; $$ language sql;
select foo(1, 2); --good
select foo(c := 3, b := 1, a := 2) --if needed

-- Singular or Plural nouns for table names
create table foo --?
create table foos --?

-- Check Constraints
create table foo (
  id integer,
  contraint_1 numeric check (contraint_1 > 0), -- Column constraint
  contraint_2 numeric check (contraint_2 > 0), -- Column constraint
  check (contraint_1 > contraint_2) -- Table constraint
) --?

create table foo (
  id integer,
  contraint_1 numeric,
  contraint_2 numeric,
  check (contraint_1 > 0), -- Column constraint
  check (contraint_2 > 0), -- Column constraint
  check (contraint_1 > contraint_2) -- Table constraint
) --?

create table foo (
  id integer,
  contraint_1 numeric,
  contraint_2 numeric,
  constraint named_constraint_1 check (contraint_1 > 0), -- Column constraint named
  constraint named_constraint_2 check (contraint_2 > 0), -- Column constraint named
  constraint named_constraint_table check (contraint_1 > contraint_2) -- Table constraint named
) --?

-- Not-Null Constraints
create table foo (
  id integer not null -- no named
) --?

create table foo (
  id integer constraint named_not_null check (id is not null) -- named
) --?

-- Unique Constraints
-- Adding a unique constraint will automatically create a unique btree index on the column or group of columns used in the constraint.
create table foo (
  id integer unique
) --?

create table foo (
  id integer,
  unique(id)
) --?

create table foo (
  id integer constraint must_be_different unique
) --?

-- Primary Keys
-- Adding a primary key will automatically create a unique btree index on the column or group of columns used in the primary key.
create table foo (
  id integer unique not null
) --?
create table foo (
  id integer primary key
) --?
create table foo (
  id integer,
  primary key (id)
) --?

-- Foreign Keys
-- Create table foo (no_foo integer primary key)
create table bar (
  no_bar integer primary key,
  no_foo integer references foo
) --?
create table bar (
  no_bar integer primary key,
  no_foo integer references foo (no_foo)
) --?
create table bar (
  no_bar integer primary key,
  no_foo integer,
  foreign key (no_foo) references foo
) --?

-- Inserting Data
-- Create table foo (a, b default 0, c, d default 1)
insert into foo values (1, 2, 3, 4); --?
insert into (a, b, c, d) values (1, 2, 3, 4); --?
insert into foo values (1, 2) --?
insert into foo values (1, 2, default, default) --?
insert into foo default values; --?

-- Qualified Joins
select * from foo join bar on foo.id = bar.id; --?
select * from foo join bar using (id); --?
select * from foo natural join bar; --?

select * from foo join bar on ...; --?
select * from foo inner join bar on ...; --?

select * from foo left join bar on ...; --?
select * from foo left outer join bar on ...; --?

select * from foo right join bar on ...; --?
select * from foo right outer join bar on ...; --?

select * from foo full join bar on ...; --?
select * from foo full outer join bar on ...; --?

-- Table and Column Aliases
from foo as named_foo --?
from foo named_foo --?

-- Syntax Good Practices
-- parameters
create table foo ();
create table foo();

create function foo ();
create function foo();

  -- Functions name
select Sum(total_foo);
select sum(total_foo);

-- Tables / Functions parameters
-- parentheses wrapper
create table/function foo (a, b, c) --?

create table/function foo (
  a,
  b,
  c
) --?

create table/function foo
(
  a,
  b,
  c
) --?

-- parameters linebreaks with comma:
-- after
create table/function foo (
  a
  , b
  , c
) --?
-- before
create table/function foo (
  a
  ,b
  ,c
) --?
-- before with space
create table/function foo (
  a
  , b
  , c
) --?

-- Functions Implementation
create function foo ...
returns type as
$$
select a, b, c;
$$ language sql; --?

create function ...
returns type
as $$
select a, b, c;
$$ language sql; --?

create function ...
returns type as
$$
select a, b, c;
$$ language sql; --?

-- default named? $defaultName$
create function ...
returns type as
$defaultName$
select a, b, c;
$defaultName$ language sql; --?

-- Simple Query
select *
from   foo
       join bar using (id)
where  foo.foo_data > bar.bar_data
       and foo.foo_item > 0
group  by foo.foo_category
having count(*) > 0
order  by foo.foo_tri
limit  10 --? left align

select *
  from foo
       join bar using (id)
 where foo.foo_data > bar.bar_data
       and foo.foo_item > 0
 group by foo.foo_category
having count(*) > 0
 order by foo.foo_tri
 limit 10 --? right align

 select *
   from foo
        join bar using (id)
  where foo.foo_data > bar.bar_data
    and foo.foo_item > 0
  group by foo.foo_category
 having count(*) > 0
  order by foo.foo_tri
  limit 10 --? and/or under where

-- Sub query
select *
  from foo
 where exists (select *
                 from baz) --?
select *
  from foo
 where exists (
                select *
                  from baz
              )--?
select *
  from foo
 where exists (
                select *
                  from baz
       )--?

select *
  from foo
 where exists (
         select *
           from baz
       ) --?

-- Complex Queries
-- Examples
-- parameters linebreaks after
with foo_with
     as (select foo.name,
                sum(foo.foo_number) as total_foo,
                foo.produit
           from foo
          group by foo.foo_tri),
     bar_with
     as (select bar.name
           from foo_with
          where total_foo > (select sum(total_foo) / 10
                               from foo_with))
select foo.name,
       foo.item,
       sum(foo.foo_count)  as units_foo,
       sum(foo.foo_number) as total_foo,
  from foo
 where foo.name in (select foo.name
                      from bar_with)
 group by foo.name,
          foo.item;

-- parameters linebreaks before
with foo_with
     as (select foo.name
                , sum(foo.foo_number) as total_foo
                , foo.produit
           from foo
          group by foo.foo_tri),
     bar_with
     as (select bar.name
           from foo_with
          where total_foo > (select sum(total_foo) / 10
                               from foo_with))
select foo.name
       , foo.item
       , sum(foo.foo_count)  as units_foo
       , sum(foo.foo_number) as total_foo,
  from foo
 where foo.name in (select foo.name
                      from bar_with)
 group by foo.name
          , foo.item;

-- Not stacked
with foo_with
     as (select foo.name, sum(foo.foo_number) as total_foo, foo.produit
           from foo
          group by foo.foo_tri),
     bar_with
     as (select bar.name
           from foo_with
          where total_foo > (select sum(total_foo) / 10
                               from foo_with))
select foo.name, foo.item, sum(foo.foo_count) as units_foo, sum(foo.foo_number) as total_foo,
  from foo
 where foo.name in (select foo.name
                      from bar_with)
 group by foo.name,foo.item;

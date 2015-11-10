Use uppercase for statements, operators and keywords
```sql
-- bad
select * from foo order by bar;

-- good
SELECT * FROM foo ORDER BY bar;
```

Use lowercase for types
```sql
-- bad
CREATE TABLE foo(bar INTEGER, baz TEXT);

-- good
CREATE TABLE foo(bar integer, baz text);
```

Do not use quotation marks for identifiers
```sql
-- bad
UPDATE "foo" SET "bar" = x;

-- good
UPDATE foo SET bar = x;
```

Use double pipe for explicit concatenation
```sql
-- bad
SELECT 'foo'
'bar';

-- bad
SELECT 'foobar';

-- good
SELECT 'foo' || 'bar';
```

Use explicit parameters (with `in_` or `out_` prefix) instead of positional parameters
```sql
-- bad
CREATE FUNCTION foo(text) RETURNS text AS $$
  SELECT $1;
$$ LANGUAGE sql;

-- bad
CREATE FUNCTION foo(bar text) RETURNS text AS $$
  SELECT bar;
$$ LANGUAGE sql;

-- good
CREATE FUNCTION foo(in_bar text) RETURNS text AS $$
  SELECT in_bar;
$$ LANGUAGE sql;
```

Array declaration
```sql
-- bad
SELECT ARRAY[1,2,3+4];

-- bad
SELECT '{1, 2, 3 + 4}';

-- good
SELECT array[1, 2, 3 + 4];
```

Use positional parameters only if needed
```sql
CREATE FUNCTION foo(in_a integer, in_b integer, in_c integer) RETURNS text AS $$
  SELECT in_a;
  SELECT in_b;
  SELECT in_c;
$$ LANGUAGE sql;

-- bad
SELECT foo(in_a := 1, in_b := 2, in_c := 3);

-- good
SELECT foo(1, 2, 3);

-- if needed
SELECT foo(in_c := 3, in_a := 1, in_b := 2);
```

Do not use casting operator while not needed
```sql
-- bad
SELECT cast('12' AS integer);

-- good
SELECT '12'::integer;
```

Use singular words for table names
```sql
--bad
SELECT * FROM bars;

-- good
SELECT * FROM bar;
```

Prefix table id with the table name
```sql
-- bad
CREATE TABLE foo(id serial);

-- good
CREATE TABLE foo(foo_id serial);
```

`NULL` and `NOT NULL` constraints have to be declared into the table declaration without explicit column reference
```sql
-- bad
CREATE TABLE foo(bar integer, NOT NULL(bar));

-- good
CREATE TABLE foo(bar integer NOT NULL);
```

`PRIMARY KEY` constraints have to be declared into the table declaration WITH explicit column reference
```sql
-- bad
CREATE TABLE foo(foo_id serial PRIMARY KEY);

-- good
CREATE TABLE foo(foo_id serial, PRIMARY KEY(foo_id));
```

Other constraints have to be declared outside of the table declaration with an explicit name based on the `*key*_*table*_on_*column*(_and_*column*)` pattern (keys are: `fkey` for `FOREIGN KEY`, `key` for `UNIQUE`, `check` for `CHECK`)
```sql
-- bad
CREATE TABLE foo(foo_id serial, bar_id integer REFERENCES bar(id));

-- good
CREATE TABLE foo(foo_id serial, bar_id integer);
ALTER TABLE foo ADD CONSTRAINT fkey_foo_on_bar_id FOREIGN KEY bar_id REFERENCES bar(id);

-- bad
CREATE TABLE foo(bar text UNIQUE);

-- good
CREATE TABLE foo(bar text);
ALTER TABLE foo ADD CONSTRAINT key_foo_on_bar UNIQUE(bar);

-- bad
CREATE TABLE foo(bar integer CHECK(bar > 1));

-- good
CREATE TABLE foo(bar integer);
ALTER TABLE foo ADD CONSTRAINT check_foo_on_bar CHECK(bar > 1);
```

Name your indexes based on the `idx_*table*_on_*column*(_and_*column*)` pattern
```sql
-- bad
CREATE INDEX ON foo(bar, baz);

-- good
CREATE INDEX idx_foo_on_bar_and_baz ON foo(bar, baz);
```

To be continued...

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

SELECT *
FROM foo
WHERE EXISTS (
  SELECT *
  FROM baz
); --?

SELECT *
FROM foo
WHERE EXISTS
(
  SELECT *
  FROM baz
); --?


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

WITH foo_with AS (
  SELECT
    foo.name,
    SUM(foo.foo_number) AS total_foo,
    foo.produit
  FROM foo
  GROUP BY foo.foo_tri
),
bar_with AS (
  SELECT
    bar.name
  FROM foo_with
  WHERE total_foo > (
    SELECT SUM(total_foo) / 10
    FROM foo_with
  )
);
SELECT
  foo.name,
  foo.item,
  sum(foo.foo_count)  AS units_foo,
  sum(foo.foo_number) AS total_foo,
FROM foo
WHERE foo.name IN (
  SELECT
    foo.name
  FROM bar_with
)
GROUP BY foo.name, foo.item; --?


with foo_with AS
(
  SELECT
    foo.name,
    SUM(foo.foo_number) AS total_foo,
    foo.produit
  FROM foo
  GROUP BY foo.foo_tri
),
bar_with AS
(
  SELECT
    bar.name
  FROM foo_with
  WHERE total_foo >
  (
    SELECT SUM(total_foo) / 10
    FROM foo_with
  )
);
SELECT
  foo.name,
  foo.item,
  SUM(foo.foo_count) AS units_foo,
  SUM(foo.foo_number) AS total_foo,
FROM foo
WHERE foo.name IN
(
  SELECT
    foo.name
  FROM bar_with
)
GROUP BY foo.name, foo.item; --?

-- Searching in Arrays --
SELECT * FROM foo WHERE 10 = any(pay); --?
SELECT * FROM foo WHERE 10 = all(pay); --?
SELECT * FROM foo WHERE pay && array[10]; --?

-- Array Constructors --
SELECT array[array[1, 2], array[3, 4]]; --?
SELECT array[[1, 2], [3, 4]]; --?

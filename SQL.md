Use uppercase for statements, operators and keywords
```sql
-- bad
SELECT * FROM foo order by bar;

-- good
SELECT * FROM foo ORDER BY bar;
```

Use lowercase for functions
```sql
-- bad
SELECT COUNT(*) FROM foo;

-- good
SELECT count(*) FROM foo;
```

Use lowercase for types
```sql
-- bad
CREATE TABLE foo(bar INTEGER, baz TEXT);

-- good
CREATE TABLE foo(bar integer, baz text);
```

Do not use quotation marks for identifiers, unless you are defining a new type (which needs camelCase notation)
```sql
-- bad
UPDATE "foo" SET "bar" = x;

-- good
UPDATE foo SET bar = x;

-- if needed
CREATE TYPE foo AS (
  "fooId" integer,
  "title" text,
  "parentId" integer
);
```

Use same difference operator as other languages.
```sql
-- bad
SELECT baz FROM foo WHERE bar <> baz;

-- good
SELECT bar FROM foo WHERE bar != baz;
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

Always specify the needed columns
```sql
-- bad
SELECT * FROM foo;

-- good
SELECT foo_id, bar_id, creation_date FROM foo;
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

Use proper array declaration
```sql
-- bad
SELECT '{1, 2, 3 + 4}';

-- bad
SELECT ARRAY[1,2,3+4];

-- good
SELECT array[1, 2, 3 + 4];
```

Specify the name of the parameters
```sql
CREATE FUNCTION foo(in_a integer, in_b integer, in_c integer) RETURNS text AS $$
  SELECT in_a;
  SELECT in_b;
  SELECT in_c;
$$ LANGUAGE sql;

-- bad
SELECT foo(1, 2, 3);

-- good
SELECT foo(in_a := 1, in_b := 2, in_c := 3);

-- if needed
SELECT foo(in_c := 3, in_a := 1, in_b := 2);
```

Do not use casting operator while not needed
```sql
-- bad
SELECT cast('bar' AS integer);

-- good
SELECT 'bar'::integer;

-- only for immutable functions
CREATE FUNCTION foo()
RETURNS text
AS $body$
  SELECT integer 'bar';
$body$ LANGUAGE sql immutable;
```

Use singular words for table names
```sql
--bad
SELECT foo FROM bars;

-- good
SELECT foo FROM bar;
```

Do not use space before parentheses while writing one-line code.
```sql
-- bad
CREATE TABLE foo ();
INSERT INTO bar (baz) VALUES (1);
CREATE FUNCTION foo_bar (in_a text) ...;

-- good
CREATE TABLE foo();
INSERT INTO bar(baz) VALUES(1);
CREATE FUNCTION foo_bar(in_a text) ...;
```

Use space before parentheses when using multi-line code and comma dangle at line end.
```sql
-- bad
CREATE table foo
(
  a,
  b,
  c
);

-- bad
CREATE table foo (
  a
  , b
  , c
);

-- good
CREATE TABLE foo (
  a,
  b,
  c
);
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

Specify table columns while inserting and do not mention those to be not defined (or defined by default)
```sql
CREATE TABLE foo(a, b default 0, c, d default 1);

-- bad
INSERT INTO foo VALUES(1, 2, 3, 4);

-- good
INSERT INTO foo(a, b, c, d) VALUES(1, 2, 3, 4);

-- bad
INSERT INTO foo(a, b, c, d) VALUES(1, default, 3, default);

-- good
INSERT INTO foo(a, c) VALUES(1, 3);
```

Do not use `NATURAL JOIN` and `JOIN USING`. It is unreliable, use instead `JOIN ON`.
```sql
-- bad
SELECT baz FROM foo NATURAL JOIN bar;

-- bad
SELECT baz FROM foo JOIN bar USING(foo_id);

-- good
SELECT baz FROM foo JOIN bar ON foo.id = bar.foo_id;
```

Do not use unnecessary `INNER` and `OUTER` statements while using `JOIN`
```sql
-- bad
SELECT baz FROM foo INNER JOIN bar ON ...;

-- good
SELECT baz FROM foo JOIN bar ON ...;
```

Separate columns and their aliases
```sql
-- bad
SELECT f.bar FROM foo f;

-- good
SELECT f.bar FROM foo AS f;
```

Always use aliases to prefix every used columns. An alias is a trigram formed by first letters of every words of a table name (with a maximum of 3). If the table name contains below 3 words, the trigram is completed by the last word letters. Collisions can occur when manipulating table name with more than 3 words. If needed, expand the trigram to more than 3 letters.
```sql
-- good (below 3 words table name)
SELECT fba.foo_bar_id FROM foo_bar AS fba;

-- good (3 words table name and above)
SELECT fbb.foo_bar_baz_id FROM foo_bar_baz AS fbb;

-- if needed
SELECT fbbz.foo_bar_baz_zoo_id FROM foo_bar_baz_zoo AS fbbz;
```

Respect proper function indentation, name the `$$` block and use multi-line parameters only if needed.
```sql
-- good
CREATE FUNCTION foo(in_a text, in_b integer)
RETURNS integer
AS $body$
  SELECT foo.id FROM foo AS foo WHERE foo.bar = in_a AND foo.baz = in_b;
$body$ LANGUAGE sql;

-- if needed
CREATE FUNCTION foo (
  in_a text,
  in_b integer
)
RETURNS integer
AS $body$
  SELECT foo.id FROM foo AS foo WHERE foo.bar = in_a AND foo.baz = in_b;
$body$ LANGUAGE sql;
```

Respect proper query indentation. Each statements have to be right-aligned for the same depth. Each depth has to be aligned one space behind its parent and is independent in terms of statements' right-alignment.
```sql
-- good
SELECT foo.id
  FROM foo AS foo
 WHERE id IN (
         SELECT bar.foo_id
           FROM bar AS bar
       );
-- good
  SELECT foo.data,
         foo.item,
         foo.category
    FROM foo AS foo
    JOIN bar AS bar
         ON foo.id = bar.id
   WHERE foo.data > bar.data
         AND foo.item > 0
GROUP BY foo.category
  HAVING count(*) > 0
ORDER BY foo.rank
   LIMIT 10;

-- good
WITH foo_with AS (
    SELECT foo.name,
           sum(foo.number) AS total_foo,
           foo.product
      FROM foo AS foo
  GROUP BY foo.name
),
bar_with AS (
  SELECT fwi.name
    FROM foo_with AS fwi
   WHERE fwi.total_foo > (
           SELECT bar.total / 10
             FROM bar AS bar
         )
);

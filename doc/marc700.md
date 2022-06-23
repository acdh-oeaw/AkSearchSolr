# MARC 700

## Introduction

MARC field 700 stores information both on authors and titles. So we need to filter based on indicator values.
Also a problem of multiple/no subfield occurences applies. We need to disaagregate to the finest granularity on the solr field level (and assure n-th value of each solr field comes from the same MARC field).

## References sources

* [MARC 700 details](https://docs.google.com/spreadsheets/d/1viPa98Qjh9m7SVn_01KbgGUBFmECfqJG_F3kOkiBUk0/edit)
* [indexer documentation](https://github.com/solrmarc/solrmarc/wiki)
* [our indexer config](https://github.com/acdh-oeaw/AkSearchSolr/blob/main/local/import/marc_local.properties)
* [vufind custom indexing methods](https://github.com/vufind-org/vufind/tree/dev/import/index_java/src/org/vufind/index), 
  particularly [for authors indexing](https://github.com/vufind-org/vufind/blob/dev/import/index_java/src/org/vufind/index/CreatorTools.java)
* Redmine issues
  * [focus on authors](https://redmine.acdh.oeaw.ac.at/issues/19489)
  * [focus on title](https://redmine.acdh.oeaw.ac.at/issues/20204)

## Examples

* 993412310604498 - many author role subfields within single 700 field
* 993498613504498, 993523208704498 - both author and title 700 fields
* 993519804104498 - many authors
* 990002457620504498 - linked fields (also with one missing link)

## Issues

1. We need to filter field `700` on 2nd indicator value to distinguish between fields holding additional title and fields holding additional authors.
  * It should be enough to switch to the standard syntax and use something like (non-set indicator value is represented by space in MARC-XML):
    ```
    author2_role = 7004?(ind2 = ' '), roles.properties
    title_alt = 130afglnp:700afglnp?(ind2 = 2):730abcdgt
    ```
  * If we need to keep the author role type filters, we can do it with syntax like:
    ```
    author_role = {1004:7004}?(ind2 = ' ' && $4 matches "adp|aut|cmp|cre|dub|inv"), roles.properties
    ```
2. We need to be able to repeat author label as many times as the author role subfield appears in the author field.
  * It looks like there's no way to express it in the indexer mapping syntax and also none of VuFind-provided methods can do it.
  * It means we need our own Java helper method - `getRepeated(specList)`, where:
    * `specList` is a colon-separated list of `singleFieldSpec`
    * `singleFieldSpec` has `{field}|{ind1}{ind2}|{value subfields}|{repeat subfield}` format, where:  
      `{field}` is just a MARC field number  
      `{ind1}` and `{ind2}` are indicator filters where `_` means "anything" and `#` means "not set"  
      `{value subfields}` is a list of subfields forming the MARC field value (they are merged using space as a separator and finally trimmed)  
      `{repeat subfield}` is a subfield which count determines the number of times the value is repeated (**but if the count is 0, the value must be returned once** to avoid skipping authors with undefined roles)
    * e.g. `author = custom, getRepeated(100|__|abcdg|4:700|_#|abcdg|4)`
  * Our helper method source is in the `java_helpers/Oeaw.java` file which is copied into docker image's `/opt/aksearch/import/index_java/src/Oeaw.java`
    (where the indexer searches for the helper methods code) by the `Dockerfile`.
3. We need to handle linked fields in 2.  
   When a value is in a linked field:
   * The original field contains subfield `6` with a value `targetTag-uniqueId`, e.g. `880-03`.
   * There is a linked field with a given tag and subfield `6` with values `srcTag-uniqueId` (e.g. `700-03`) or `srcTag-uniqueId/somethingElse` (e.g. `700-03/Jpn`).
   * It is possible that not all fields have the `6` subfield. In such a case a default value should be used.
4. While extracting subfield values we need to be able to provide a default value when the subfield is missing.
   * This is done by the second Java helper method - `getSubfieldAtLeastOnce({field}|{ind1}{ind2}|{value subfield}, {default value})`, where:
    * `{field}` is just a MARC field number  
      `{ind1}` and `{ind2}` are indicator filters where `_` means "anything" and `#` means "not set"  
      `{value subfield}` is the code of the subfield to be indexed (each instance of this subfield, even in the same field, will be indexed as a separate Solr field value)  
      `{default value}` is the value to be indexed when the subfield doesn't exist for a given field
    * e.g. `author2_role = custom, getSubfieldAtLeastOnce(700|_#|4, und)`
    * Helper method source is in the `java_helpers/Oeaw.java` file which is copied into docker image's `/opt/aksearch/import/index_java/src/Oeaw.java`
    (where the indexer searches for the helper methods code) by the `Dockerfile`.

## Use case

Given a MARC record with these fields:
```
700 $a Arguillère, Stéphane $4 trl $4 wst
700 $a Smith, John
700 $a Mustermann, Max $4 trl $6 880-01
880 $a Foo, Bar $6 700-01
```

the following index specification:
```
author2 = custom, getRepeated(700|_#|abcdg|4)
author2_original-writing_str_mv = custom, getRepeated(700|_#|@abcdg|4|noLinkedField)
author2_role = custom, getSubfieldAtLeastOnce(700|_#|4, und)
```
the Solr index will be populated as follows.

**author2**
```
Arguillère, Stéphane
Arguillère, Stéphane
Smith, John
Mustermann, Max
```

**author2_original-writing_str_mv**
```
noLinkedField
noLinkedField
Foo, Bar
```

**author2_role**
```
trl
wst
und
trl
```
(Of course, these values can be translated to more understandable definitions by specifying a translation map)

# MARC 700

## Introduction

DACH-MARC uses a dedicated `<<part to omit>>` syntax to mark parts of the value which should be skipped for sorting.

# Reference sources

* [indexer documentation](https://github.com/solrmarc/solrmarc/wiki),
  especially [creating custom mapping methods](https://github.com/solrmarc/solrmarc/wiki/Defining-and-Using-Custom-Methods#creating-custom-mapping-methods)
* [our indexer config](https://github.com/acdh-oeaw/AkSearchSolr/blob/main/local/import/marc_local.properties)
* Redmine issues
  * [Remove Sorting Escape Characters from display](https://redmine.acdh.oeaw.ac.at/issues/20336)

## Examples

* 990003019480504498
* AC02636029, AC01451642 - with additional `=` character at the beginning of the MARC `245b` 

## Discussion

There are two possible approaches to handle this issue:

* Handle it in the GUI (VuFind).
  * The GUI makes a map from values with `<<part to omit>>` skipped as map keys and values without `<<` and `>>` as map values.
  * The GUI sorts the map by key.
  * The GUI uses sorted map values.
* Handle it during the indexing by creation of two "sibling" properties
  * The value(s) to be used for sorting (with `<<part to omit>>` skipped).
  * The value(s) to be used for display (with `<<` and `>>` removed).
  In this case we would also like to skip the `<<` and `>>` tags from the _fullrecord_ solr property storing the whole record as an MARC XML.

The problem with the first approach is that it for handling search results paging it would require the GUI to fetch a complete set of results
because the right sorting can be done only on the GUI side. This is, pretty obviously, not feasible.

Which leaves us with the second solution.

By the way the AkSearch just uses a [helper GUI method](https://biapps.arbeiterkammer.at/gitlab/open/aksearch/module-core/blob/master/src/AkSearch/RecordDriver/MarcAdvancedTrait.php#L1141)
to strip `<<` and `>>` but this approach doesn't assure proper sorting.

# Solution

Develop custom indexer mapping methods (see the `{repoRoot}/java_helpers/Oeaw.java`):

* `skipTagsAndSort(skipContent)` to be applied as a postprocessing filter to any extracted field if solr index values should be sorted.
* `skipTags(skipContent)` to be applied as a postprocessing filter to any extracted field if solr index values should preserve order from the MARC record.
* `skipTagsFromFullRecord()` to be applied to the _fullrecord_ solr field.

Usage examples:

```
fullrecord = FullRecordAsXML, custom_map(Oeaw skipTagsFromFullRecord)

someFieldToDisplay = custom, getAuthorsFilteredByRelator(110abg:111abcg:710abg:711abg,110:111:710:711,firstAuthorRoles|secondAuthorRoles), custom_map(Oeaw skipTagsAndSort(false))
someFieldToSort = custom, getAuthorsFilteredByRelator(110abg:111abcg:710abg:711abg,110:111:710:711,firstAuthorRoles|secondAuthorRoles), custom_map(Oeaw skipTagsAndSort(true))

otherFieldForDisplay = 245ab, first, custom_map(Oeaw skipTagsAndSort(false))
otherFieldForSort = 245ab, first, custom_map(Oeaw skipTagsAndSort(true))
```

Remarks:

* Sibling properties creation is needed only if a give property is used for sorting results of search.
  If it's not a case, a single property with `custom_map(Oeaw skipTagsAndSort(false))` applied is enough.

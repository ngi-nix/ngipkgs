import "meta" as $meta;
import "derivations" as $drvs;

$meta | add as $meta |
$drvs | add as $drvs |
[(($meta | keys_unsorted) + ($drvs | keys_unsorted)) | unique | .[] |
{ key: ., value: { meta: $meta[.], derivation: $drvs[.] } }] | from_entries

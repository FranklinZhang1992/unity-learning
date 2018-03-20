open Printf

let main() =
  let str0 = "" in
  let str1 = "" in
  let str2 = ref "" in
  let str3 = sprintf "%s" str0 in
  let str4 = ref str3 in
  if str1 = !str2 then
    printf "str1 = str2\n"
  else
    printf "str1 <> str2\n";

  if str1 = sprintf "%s" !str4 then
    printf "str1 = str4\n"
  else
    printf "str1 <> str4\n";
;;

main();

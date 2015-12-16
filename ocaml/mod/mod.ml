open Printf

let convert_disk_size_mb size_b =
  printf "origin size = %d\n" size_b;
  if (size_b / (1024 * 1024) * (1024 * 1024)) = size_b then
    printf "yes1\n"
  else if ((size_b + 2048) / (1024 * 1024) * (1024 * 1024)) = (size_b + 2048) then
    printf "yes2\n"
  else
    printf "size_b\n";
;;

let main () =
  let size = 10498340864 in
  let size1 = size / (1024 * 1024) + 1 in
  printf "size1 = %d\n" size1;
  convert_disk_size_mb size;
;;

main ();;

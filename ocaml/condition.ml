open Printf

let main =
  let fin_sector_size = ref "" in
  let sector_size = "4KB" in
  printf "%s\n" sector_size;
  if sector_size = "4KB" then
    fin_sector_size := "4096"
  else
    fin_sector_size := "512";
  printf "fin_sector_size = %s\n" !fin_sector_size;
;;

main

(lang dune 3.16)

(name mirage-unikraft)

(generate_opam_files true)

(source
 (github shym/mirage-unikraft))

(authors "Fabrice Buoro" "Samuel Hym")

(maintainers "Fabrice Buoro" "Samuel Hym")

(license MIT)

(package
 (name mirage-unikraft)
 (synopsis "Unikraft core platform libraries for MirageOS")
 (description
  "This packages provides the MirageOS `OS` library for Unikraft targets.")
 (depends ocaml dune mirage-runtime mirage-unix bheap lwt cstruct metrics duration)
 (tags ("org:mirage")))

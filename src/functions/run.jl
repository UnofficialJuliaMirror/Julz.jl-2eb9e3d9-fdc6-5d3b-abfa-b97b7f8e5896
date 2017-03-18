function run()

  package_name = rsplit(pwd(), "/"; limit=2)[2]

  package_dir = rsplit(dirname(@__FILE__), "/"; limit=4)[1]

  target_name = replace(package_name, ".jl", "")

  target_path = "$package_dir/$target_name"

  if target_path != pwd()
    initial_dir = pwd()

    cd("..")
    cp(package_name, target_path, remove_destination=true)
    cd(initial_dir)
  end

  if !isdefined(Symbol(target_name))
    eval(parse("using $target_name"))
  end

  eval(parse("$target_name.main()"))

end

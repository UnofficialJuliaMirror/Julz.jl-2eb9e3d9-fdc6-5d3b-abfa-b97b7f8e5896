function run(args::Dict)
  run()
end

function run()

  package_name = rsplit(pwd(), "/"; limit=2)[2]

  package_dir = rsplit(dirname(@__FILE__), "/"; limit=9)[1]

  target_name = replace(package_name, ".jl", "")

  target_path = "$package_dir/$target_name"

  if target_path != pwd()
    cd("..") do
      cp(package_name, target_path, remove_destination=true)
    end
  end

  if !isdefined(Symbol(target_name))
    eval(parse("using $target_name"))
  end

  eval(parse("$target_name.main()"))

end

function init(args::Dict)
  init()
end

function init()

  parent_folders = [
    "src",
    "test"
  ]

  folders = [
    "functions",
    "constants",
    "macros",
    "types"
  ]

  touch("$(pwd())/input.jl")

  remove_default_test()
  remove_default_comments()

  for parent_folder in parent_folders
    add_code_to_main_file(parent_folder)

    for folder in folders
      folder_path = "$(pwd())/$parent_folder/$folder"
      if isdir(folder_path) ; continue ; end

      mkdir(folder_path)
      touch("$folder_path/.keep")
    end
  end

  setup_base_dir()
  setup_config()
  setup_docs()

end

function remove_default_comments()
  package_name = replace(rsplit(pwd(), "/"; limit=2)[2], ".jl", "")

  main_file_path = "$(pwd())/src/$package_name.jl"
  main_file_text = readstring(main_file_path)

  line_1 = "# package code goes here"
  line_2 = "end # module"
  default_main = "\n$line_1\n\n$line_2"

  new_file = replace(main_file_text, default_main, "\nend")
  open(main_file_path, "w") do old_file
    write(old_file, new_file)
  end
end

function remove_default_test()
  test_file_path = "$(pwd())/test/runtests.jl"
  test_file_text = readstring(test_file_path)

  line_1 = "# write your own tests here"
  line_2 = "@test 1 == 2"
  default_test = "\n$line_1\n$line_2\n"

  new_file = replace(test_file_text, default_test, "")
  open(test_file_path, "w") do old_file
    write(old_file, new_file)
  end
end

function add_code_to_main_file(parent_folder)
  package_name = replace(rsplit(pwd(), "/"; limit=2)[2], ".jl", "")
  if package_name == "Julz" ; return ; end

  template_dictionary = Dict()

  template_dictionary["src"] = ("package", package_name, "module")
  template_dictionary["test"] = ("runtests", "runtests", "")

  template_name, file_name, buzz_word = template_dictionary[parent_folder]

  template_path = "$(dirname(@__FILE__))/../../../templates/$parent_folder/$(template_name).jl"
  file_path = "$(pwd())/$parent_folder/$file_name.jl"

  template = readlines(template_path)
  file = readlines(file_path)

  insert_index = length(file)
  for (index, file_line) in enumerate(file)
    if ismatch(r"(?<!\w)Julz(?!\w)", file_line) ; return ; end
    if contains(file_line, buzz_word) && buzz_word != ""
      if insert_index == length(file)
        insert_index = index
      end
    end
  end

  unshift!(template, file[insert_index])
  splice!(file, insert_index, template)

  open(file_path, "w") do old_file
    write(old_file, file)
  end
end

function setup_base_dir()

  open(".gitignore", "a") do gitignore_file
    write(gitignore_file, "\n.DS_Store")
    write(gitignore_file, "\ndocs/build/**/*")
  end

  open("REQUIRE", "a") do require_file
    write(require_file, "Julz")
  end

  package_name = replace(rsplit(pwd(), "/"; limit=2)[2], ".jl", "")

  cfg = LibGit2.GitConfig(LibGit2.Consts.CONFIG_LEVEL_GLOBAL)
  user_email = LibGit2.get(cfg, "user.email", "")

  travis_script = "script:
 - if [[ -a .git/shallow ]]; then git fetch --unshallow; fi
 - julia -e 'Pkg.clone(pwd());'
 - (echo \"y\" && echo \"$package_name Test\" && echo \"$user_email\" && echo \"$package_name Test\" && echo \"n\" && yes && cat) | julia -e 'using PkgDev; PkgDev.config();'
 - julia -e 'Pkg.build(\"$package_name\"); Pkg.test(\"$package_name\"; coverage=true)'"

  open(".travis.yml", "a") do require_file
    write(require_file, travis_script)
  end

end

function setup_config()

  config_dir = "$(pwd())/config"

  mkdir(config_dir)
  mkdir("$config_dir/initializers")
  touch("$config_dir/initializers/.keep")

  file_path = "$config_dir/bootload.jl"
  bootload_file = generate_file_template("config", "bootload")
  open(file_path, "w") do file
    write(file, bootload_file)
  end

end

function setup_docs()

  mkdir("$(pwd())/docs")
  mkdir("$(pwd())/docs/src")

  file_path = "$(pwd())/docs/make.jl"
  make_file = generate_file_template("docs", "make")
  open(file_path, "w") do file
    write(file, make_file)
  end

  file_path = "$(pwd())/docs/src/index.md"
  make_file = generate_file_template("docs", "index.md")
  open(file_path, "w") do file
    write(file, make_file)
  end

end

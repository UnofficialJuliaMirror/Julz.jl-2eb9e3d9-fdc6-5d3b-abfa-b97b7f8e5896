function include_all_files(cur_item; is_testing=false, reload_function=Nullable)
  loaded_files = []
  all_files = get_all_files(cur_item, is_testing=is_testing)
  unloaded_files = setdiff(all_files, loaded_files)

  while length(unloaded_files) > 0
    new_file_count = 0

    for file in all_files
      is_already_loaded = in(file, loaded_files)
      if is_already_loaded ; continue ; end

      try
        include(file)

        if is_testing
          if reload_function == Nullable
            error("Need to pass reload_function for tests")
          end

          input_file_name = "$main_folder/input.jl"
          reload_function(input_file_name, true)
        end
      catch
        continue
      end

      push!(loaded_files, file)
      new_file_count += 1
    end

    unloaded_files = setdiff(all_files, loaded_files)

    if new_file_count == 0
      bad_file = unloaded_files[1]
      println(bad_file)
      include(bad_file)
    end
  end
end

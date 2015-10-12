namespace :copy do
  archive_name = "archive.tar.gz"
  local_path = fetch(:local_path)

  unless local_path.nil?

    desc "Archives files to #{archive_name}"
    file archive_name do |t|
      sh "tar -cz -f #{t.name} #{local_path}"
    end

    desc "Deploy #{archive_name} to release_path"
    task :deploy => archive_name do |t|
      unless @deployed
        @deployed = true
        tarball = t.prerequisites.first

        on roles(:all) do
          # Make sure the release directory exists
          execute :mkdir, "-p", release_path

          # Create a temporary file on the server
          tmp_file = capture("mktemp")

          # Upload the archive, extract it and finally remove the tmp_file
          upload!(tarball, tmp_file)
          execute :tar, "-xzf", tmp_file, "-C", release_path
          execute :rm, tmp_file

          unless File.file? local_path
            # move dist folder to root
            execute :mv, release_path.join("#{local_path}/*"), release_path
            execute :rm, '-rf', release_path.join(local_path)
          end

          Rake::Task["deploy:symlink:release"].invoke
          Rake::Task['deploy:finishing'].invoke
        end

        Rake::Task["copy:clean"].invoke
      end
    end

    task :clean do |t|
      File.delete archive_name if File.exists? archive_name
    end

    task :create_release => :deploy
    task :check
    task :set_current_revision
  end
end

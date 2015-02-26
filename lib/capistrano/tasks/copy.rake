namespace :copy do

  archive_name = "archive.tar.gz"
  include_dir  = fetch(:include_dir) || "*"
  exclude_dir  = Array(fetch(:exclude_dir))
  base_dir = fetch(:base_dir) || "dist"
  @deployed = false

  exclude_args = exclude_dir.map { |dir| "--exclude '#{dir}'"}

  # Defalut to :all roles
  tar_roles = fetch(:tar_roles, 'all')

  desc "Archive files to #{archive_name}"
  file archive_name => FileList[File.join(base_dir)].exclude(archive_name) do |t|
    cmd = ["tar -cvz -f #{t.name} #{base_dir}"]
    sh cmd.join(' ')
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

        # move dist folder to root
        execute :mv, release_path.join("#{base_dir}/*"), release_path
        execute :rm, '-rf', release_path.join(base_dir)

        Rake::Task["deploy:symlink:release"].invoke
        Rake::Task['deploy:finishing'].invoke
      end

      Rake::Task["copy:clean"].invoke
    end
  end

  task :clean do |t|
    # Delete the local archive
    File.delete archive_name if File.exists? archive_name
  end

  task :create_release => :deploy
  task :check
  task :set_current_revision
end

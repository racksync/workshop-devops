# Linux Commands for Beginners

## Introduction

This lesson introduces basic Linux commands. It covers fundamental commands for navigating the file system, managing files and directories, and basic text manipulation.

## Basic Navigation

- **pwd**: Print the current working directory.
  ```bash
  pwd
  ```

- **ls**: List directory contents.
  ```bash
  ls -la
  ```

- **cd**: Change directory.
  ```bash
  cd /path/to/directory
  ```

## File and Directory Management

- **mkdir**: Create a new directory.
  ```bash
  mkdir my_directory
  ```

- **rmdir**: Remove an empty directory.
  ```bash
  rmdir my_directory
  ```

- **rm**: Remove files or directories.
  ```bash
  rm filename
  # To remove a directory and its contents:
  rm -r directory_name
  ```

## File Handling

- **cp**: Copy files or directories.
  ```bash
  cp source_file destination_file
  ```

- **mv**: Move or rename files or directories.
  ```bash
  mv old_name new_name
  ```

- **touch**: Create an empty file.
  ```bash
  touch new_file.txt
  ```

## Viewing and Editing Files

- **cat**: View file contents.
  ```bash
  cat file.txt
  ```

- **nano** or **vim**: Edit files.
  ```bash
  nano file.txt
  # or
  vim file.txt
  ```

## Additional Tips

- Use **man** followed by a command to see its manual.  
  Example:
  ```bash
  man ls
  ```

- Use **--help** with most commands to get a quick overview of options.  
  Example:
  ```bash
  cp --help
  ```

## Conclusion

Practice these commands on your Linux system to get comfortable with the command line. Experiment with command options and refer to the man pages or online resources for more in-depth information.

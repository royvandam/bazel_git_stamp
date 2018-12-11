import subprocess
import os
import string

def get_ref_path_from_head(path):
  with open(path, 'r') as handle:
    ref = handle.readline()
  return ref.split(':')[-1].strip()

def get_sha_from_ref(path):
  with open(path, 'r') as handle:
    sha = handle.readline()
  return sha.strip();

if __name__ == '__main__':
  import argparse
  parser = argparse.ArgumentParser()
  parser.add_argument('head', help="The Git HEAD file.")
  parser.add_argument('-o', '--output',
      help="The output file.", required=True)
  parser.add_argument('-t', '--template',
      help="The template input file.", required=True)
  parser.add_argument('-n', '--needle',
      help="Needle in the input file to be replaced with the Git hash. (default: $GIT_HASH)", default='GIT_HASH')
  parser.add_argument('-s', '--short', action="store_true",
      help="Use the short hash form")
  args = parser.parse_args()

  # Get the root of the git folder.
  git_path = os.path.dirname(args.head)

  # Fetch the current ref path
  ref_path = os.path.join(git_path, get_ref_path_from_head(args.head))  

  # Extract the sha from the ref path
  sha = get_sha_from_ref(ref_path)
  if args.short:
    sha = sha[:8]

  # Read, replace and write template file to output.
  with open(args.output, 'w') as out:
    with open(args.template, 'r') as template:
      for line in template:
        out.write(string.Template(line).substitute({args.needle.replace('$',''): sha}))

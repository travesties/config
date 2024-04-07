import os


def clean_path():
    # grab $PATH
    path = os.environ["PATH"].split(":")
    # normalize all paths
    path = map(os.path.normpath, path)
    # remove duplicates via a dictionary
    clean = dict.fromkeys(path)
    # combine back into one path
    clean_path = ":".join(clean.keys())
    # dump to stdout
    print(f"PATH={clean_path}")


if __name__ == "__main__":
    clean_path()

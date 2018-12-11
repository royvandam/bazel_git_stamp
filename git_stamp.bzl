def _git_stamp_impl(ctx):
    args = [
        ctx.file._script.path, 
        "-o", ctx.outputs.output.path,
        "-t", ctx.file.template.path, 
        "-n", ctx.attr.needle,
        ctx.file.head.path
    ]

    if ctx.attr.short_hash:
      args.append('-s')

    ctx.actions.run(
        executable = "python3",
        arguments = args,
        inputs = [
            ctx.file._script,
            ctx.file.head,
            ctx.file.template
        ] + ctx.files.refs,
        outputs = [
            ctx.outputs.output
        ],
    )

git_stamp = rule(
    implementation = _git_stamp_impl,
    attrs = {
        "output": attr.output(
            mandatory = True),
        "template": attr.label(
            mandatory = True,
            allow_single_file = True),
        "head": attr.label(
            mandatory = True,
            allow_single_file = True),
        "refs": attr.label_list(
            mandatory = True,
            allow_files = True),
        "needle": attr.string(
            default = "GIT_REVISION"),
        "short_hash": attr.bool(
            default = True),
        "_script": attr.label(
            default = "//:git_stamp.py",
            allow_single_file = [".py"])
    },

)

def git_stamp_init():
    native.filegroup(
      name = "git_stamp_head",
      srcs = [ ".git/HEAD" ],
      visibility = ["//visibility:public"],
    )

    native.filegroup(
      name = "git_stamp_refs",
      srcs = native.glob([".git/refs/**"]),
      visibility = ["//visibility:public"],
    )

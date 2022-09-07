import iris
import glob
import numpy as np
import stashvar_cmip6 as stashvar


def get_name(c):
    stashcode = c.attributes['STASH']
    itemcode = 1000*stashcode.section + stashcode.item
    umvar = stashvar.StashVar(itemcode)

    var_name = umvar.uniquename
    if var_name:
        if any([m.method == 'maximum' for m in c.cell_methods]):
            var_name += "_max"
        if any([m.method == 'minimum' for m in c.cell_methods]):
            var_name += "_min"

    return var_name


exp = glob.glob(
    "/scratch/tm70/kr4383/access-esm/archive/esm-historical/*/atmosphere/*"
)

for name in exp:
    is_valid = ("a.pe" in name) or ("a.pa" in name)
    is_valid &= not ".nc" in name
    if is_valid:
        print(name)
        break

um_cubes = iris.load(name)
nc_cubes = iris.load(name + ".nc")

um_names = [get_name(cube) for cube in um_cubes]
nc_names = [cube.var_name for cube in nc_cubes]

for name, um_cube in zip(um_names, um_cubes):
    idx = nc_names.index(name)
    nc_cube = nc_cubes[idx]
    print((nc_cube.data == um_cube.data).all())
    print(np.allclose(nc_cube.data, um_cube.data))
    print(nc_cube.data.dtype, um_cube.data.dtype)
    print()

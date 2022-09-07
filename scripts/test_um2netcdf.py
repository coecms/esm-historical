import iris
import glob
import numpy as np
import stashvar_cmip6 as stashvar


def get_name(c):
    """
    Converts the UM name to the new NetCDF name.
    """
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
    "./archive/*/atmosphere/*"
)

# loop through all the output files
for fp in exp:
    is_valid = ("a.pe" in fp) or ("a.pa" in fp)
    is_valid &= not ".nc" in fp
    if is_valid:
        print(f"Comparing {fp} and {fp + '.nc'}")

        um_cubes = iris.load(fp)
        nc_cubes = iris.load(fp + ".nc")

        um_names = [get_name(cube) for cube in um_cubes]
        nc_names = [cube.var_name for cube in nc_cubes]

        for name, um_cube in zip(um_names, um_cubes):
            # find corresponding variable in NetCDF file
            idx = nc_names.index(name)
            nc_cube = nc_cubes[idx]
            # check that the values are equal after rounding to float32
            assert (nc_cube.data == um_cube.data.astype(np.float32)).all()

        # quickly test one file 
        break

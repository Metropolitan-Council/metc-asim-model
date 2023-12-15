# crop marin tvpb example data processing to one county
# Ben Stabler, ben.stabler@rsginc.com, 09/17/20

import os
import pandas as pd
import openmatrix as omx
import argparse
import numpy as np

MAZ_OFFSET = 0

MAZ_LIST = [402, 409, 410, 411, 412, 413, 414, 415, 471, 472, 473, 474, 475, 476, 477, 478, 479, 
    480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 493, 494, 495, 496, 497, 498, 499, 
    500, 501, 506, 508, 509, 512, 535, 545, 1212, 1213, 1214, 1217, 1232, 1233, 1234, 1235, 1236, 
    1237, 1238, 1239, 1240, 1280, 1281, 1282, 1284, 1285, 1286, 1287, 1288, 1289, 1290, 1291, 1292, 
    1293, 1294, 1295, 1296, 1297, 1298, 1299, 1300, 1301, 1302, 1303, 1304, 1305, 1306, 1307, 1308, 
    1309, 1310, 1311, 1312, 1313, 1314, 1315, 1316, 1317, 1318, 1319, 1320, 1321, 1322, 1323, 1324, 
    1325, 1326, 1327, 1328, 1329, 1330, 1331, 1332, 1333, 1334, 1335, 1336, 1337, 1339, 1340, 1341, 
    1342, 1343, 1344, 1348, 1349, 1350, 1468, 1469, 1470, 1471, 1472, 1473, 1474, 1475, 1476, 1477, 
    1478, 1479, 1480, 1481, 1482, 1483, 1484, 1485, 1486, 1487, 1488, 1489, 1490, 1491, 1492, 1493, 
    1494, 1495, 1496, 1497, 1498, 1499, 1500, 1501, 1502, 1503, 1504, 1505, 1506, 1507, 1508, 1509, 
    1510, 1511, 1512, 1513, 1514, 1515, 1516, 1517, 1518, 1519, 1520, 1521, 1522, 1523, 1524, 1525, 
    1526, 1527, 1528, 1529, 1530, 1531, 1532, 1534, 1538, 1539, 1540, 1541, 1542, 1543, 1544, 1549, 
    1550, 1551, 1552, 1557, 1558, 1559, 1560, 1561, 1562, 1567, 1568, 1569, 1570, 1571, 1572, 1576, 
    1577, 1578, 1579, 1580, 2058, 2059, 2062, 2063, 2064, 2065, 2073, 2575, 2576, 2577, 2578, 2579, 
    2581, 2580]


segments = {"crop": {"ZONEID": np.array(MAZ_LIST)}}

parser = argparse.ArgumentParser(description="crop raw_data")
parser.add_argument(
    "segment_name",
    metavar="segment_name",
    type=str,
    nargs=1,
    help=f"geography segmentation (e.g. full)",
)

parser.add_argument(
    "-c",
    "--check_geography",
    default=False,
    action="store_true",
    help="check consistency of MAZ, TAZ, TAP zone_ids and foreign keys & write orphan_households file",
)

args = parser.parse_args()


segment_name = args.segment_name[0]
check_geography = args.check_geography

assert segment_name in segments.keys(), f"Unknown seg: {segment_name}"

input_dir = r"E:\Met_Council\metc-asim-model\Input\socioeconomic"
skims_dir = r'E:\Met_Council\metc-asim-model\Base_2018\OMX'
output_dir = f"./data_{segment_name}"


print(f"segment_name {segment_name}")

print(f"input_dir {input_dir}")
print(f"output_dir {output_dir}")

print(f"check_geography {check_geography}")

if not os.path.isdir(output_dir):
    print(f"creating output directory {output_dir}")
    os.mkdir(output_dir)


def input_path(file_name):
    return os.path.join(input_dir, file_name)


def output_path(file_name):
    return os.path.join(output_dir, file_name)


def patch_maz(df, maz_offset):
    for c in df.columns:
        if c in ["maz", "OMAZ", "DMAZ", "mgra", "orig_mgra", "dest_mgra"]:
            df[c] += maz_offset
    return df


def read_csv(file_name):
    df = pd.read_csv(input_path(file_name))
    print(f"read {file_name} {df.shape}")
    return df


def to_csv(df, file_name):
    df.to_csv(output_path(file_name), index=False)
    print(f"write {file_name} {df.shape}")


def crop_omx(omx_file_name, zones, num_outfiles=1):
    skim_data_type = np.float32
    omx_in = omx.open_file(os.path.join(skims_dir, f"{omx_file_name}.omx"))
    print(f"omx_in shape {omx_in.shape()}")

    offset_map = None
    for mapping_name in omx_in.listMappings():
        _offset_map = np.asanyarray(omx_in.mapentries(mapping_name))
        if (
            offset_map is not None
            or not (_offset_map == np.arange(1, len(_offset_map) + 1)).all()
        ):
            assert offset_map is None or (offset_map == _offset_map).all()
            offset_map = _offset_map

    if offset_map is not None:
        om = pd.Series(offset_map)
        om = om[om.isin(zones.values)]
        nm = om[~om.isin(zones.values)]
        indexes = om.index.values

    else:
        indexes = zones.index.tolist()  # index of TAZ in skim (zero-based, no mapping)
    labels = zones.values  # TAZ zone_ids in omx index order

    # create
    if num_outfiles == 1:
        omx_out = [omx.open_file(output_path(f"{omx_file_name}.omx"), "w")]
    else:
        omx_out = [
            omx.open_file(output_path(f"{omx_file_name}{i + 1}.omx"), "w")
            for i in range(num_outfiles)
        ]

    for omx_file in omx_out:
        omx_file.create_mapping("zone_number", labels)

    iskim = 0
    for mat_name in omx_in.list_matrices():
        # make sure we have a vanilla numpy array, not a CArray
        m = np.asanyarray(omx_in[mat_name]).astype(skim_data_type)
        m = m[indexes, :][:, indexes]
        print(f"{mat_name} {m.shape}")

        omx_file = omx_out[iskim % num_outfiles]
        omx_file[mat_name] = m
        iskim += 1

    omx_in.close()

    for omx_file in omx_out:
        omx_file.close()


# non-standard input file names

LAND_USE = "land_use.csv"
HOUSEHOLDS = "synthetic_households.csv"
PERSONS = "synthetic_persons.csv"
MAZ_TAZ = "maz.csv"
TAP_MAZ = "tap.csv"
TAZ = "taz.csv"
SUBZONE = "subzoneData.csv"


if check_geography:

    # ######## check for orphan_households not in any maz in land_use
    land_use = read_csv(LAND_USE)
    land_use = land_use[["maz", "taz"]]
    land_use = land_use.sort_values(["taz", "maz"])

    households = read_csv(HOUSEHOLDS)
    orphan_households = households[~households.maz.isin(land_use.maz)]
    print(f"{len(orphan_households)} orphan_households")

    # write orphan_households to INPUT directory (since it doesn't belong in output)
    if len(orphan_households) > 0:
        file_name = "orphan_households.csv"
        print(
            f"writing {file_name} {orphan_households.shape} to {input_path(file_name)}"
        )
        orphan_households.to_csv(input_path(file_name), index=False)

    # ######## check that land_use and maz and taz tables have same MAZs and TAZs

    # could just build maz and taz files, but want to make sure PSRC data is right

    land_use = read_csv(LAND_USE)
    # assert land_use.set_index('MAZ').index.is_monotonic_increasing

    land_use = land_use.sort_values("maz")
    maz = read_csv(MAZ_TAZ).sort_values("MAZ")

    # ### FATAL ###
    if not land_use.maz.isin(maz.MAZ).all():
        print(
            f"land_use.MAZ not in maz.MAZ\n{land_use.maz[~land_use.maz.isin(maz.maz)]}"
        )
        # raise RuntimeError(f"land_use.MAZ not in maz.MAZ")

    if not maz.MAZ.isin(land_use.maz).all():
        print(f"maz.MAZ not in land_use.MAZ\n{maz.maz[~maz.maz.isin(land_use.maz)]}")

    # ### FATAL ###
    if not land_use.taz.isin(maz.TAZ).all():
        print(
            f"land_use.TAZ not in maz.TAZ\n{land_use.taz[~land_use.taz.isin(maz.taz)]}"
        )
        raise RuntimeError(f"land_use.TAZ not in maz.TAZ")

    if not maz.TAZ.isin(land_use.taz).all():
        print(f"maz.TAZ not in land_use.TAZ\n{maz.taz[~maz.taz.isin(land_use.taz)]}")


# land_use
land_use = read_csv(LAND_USE)
ur_land_use = land_use.copy()

slicer = segments[segment_name]
print(land_use.columns)
for slice_col, slice_values in slicer.items():
    # print(f"slice {slice_col}: {slice_values}")
    land_use = land_use[land_use[slice_col].isin(slice_values)]

print(f"land_use shape after slicing {land_use.shape}")
to_csv(land_use, "land_use.csv")


# TAZ
taz = pd.DataFrame({"ZONEID": sorted(ur_land_use.ZONEID.unique())})
taz = taz[taz.ZONEID.isin(land_use["ZONEID"])]
to_csv(taz, TAZ)

# maz_taz
if os.path.exists(MAZ_TAZ):
    maz_taz = read_csv(MAZ_TAZ).sort_values("MAZ")
    maz_taz = maz_taz[maz_taz.MAZ.isin(land_use.maz)]
    to_csv(maz_taz, MAZ_TAZ)

# tap
if os.path.exists(TAP_MAZ):
    taps = read_csv(TAP_MAZ)
    taps = taps[["TAP", "MAZ"]].sort_values(by="TAP").reset_index(drop=True)
    taps = taps[taps["MAZ"].isin(land_use["maz"])]
    to_csv(taps, "tap.csv")

# maz to tap
if os.path.exists("maz_to_tap_walk.csv"):
    maz_tap_walk = read_csv("maz_to_tap_walk.csv").sort_values(["MAZ", "TAP"])
    maz_tap_walk = maz_tap_walk[
        maz_tap_walk["MAZ"].isin(land_use["maz"])
        & maz_tap_walk["TAP"].isin(taps["TAP"])
    ]
    to_csv(maz_tap_walk, "maz_to_tap_walk.csv")
if os.path.exists("maz_to_tap_drive.csv"):
    taz_tap_drive = read_csv("maz_to_tap_drive.csv").sort_values(["MAZ", "TAP"])
    taz_tap_drive = taz_tap_drive[
        taz_tap_drive["MAZ"].isin(land_use["maz"])
        & taz_tap_drive["TAP"].isin(taps["TAP"])
    ]
    to_csv(taz_tap_drive, "maz_to_tap_drive.csv")

# maz to maz
if os.path.exists("maz_to_maz_walk.csv"):
    maz_maz_walk = read_csv("maz_to_maz_walk.csv").sort_values(["OMAZ", "DMAZ"])
    maz_maz_walk = maz_maz_walk[
        maz_maz_walk["OMAZ"].isin(land_use["maz"])
        & maz_maz_walk["DMAZ"].isin(land_use["maz"])
    ]
    to_csv(maz_maz_walk, "maz_to_maz_walk.csv")

if os.path.exists("maz_to_maz_bike.csv"):
    maz_maz_bike = read_csv("maz_to_maz_bike.csv").sort_values(["OMAZ", "DMAZ"])
    maz_maz_bike = maz_maz_bike[
        maz_maz_bike["OMAZ"].isin(land_use["maz"])
        & maz_maz_bike["DMAZ"].isin(land_use["maz"])
    ]
    to_csv(maz_maz_bike, "maz_to_maz_bike.csv")

# tap_lines
if os.path.exists("tapLines.csv"):
    tap_lines = read_csv("tapLines.csv")
    tap_lines = tap_lines[tap_lines["TAP"].isin(taps["TAP"])]
    to_csv(tap_lines, "tapLines.csv")

# households
households = read_csv(HOUSEHOLDS)
households = households[households["TAZ"].isin(land_use["ZONEID"])]
to_csv(households, "households.csv")

# persons
persons = read_csv(PERSONS)
persons = persons[persons["household_id"].isin(households["household_id"])]
to_csv(persons, "persons.csv")

# Subzone (added ASR)
if os.path.exists(SUBZONE):
    subzone = read_csv(SUBZONE)
    subzone = subzone[subzone["subzone09"].isin(land_use["maz"])]
    to_csv(subzone, "subzone.csv")

# skims
crop_omx("allskims_L", taz.ZONEID, num_outfiles=(4 if segment_name == "full" else 1))
crop_omx("allskims_M", taz.ZONEID, num_outfiles=(4 if segment_name == "full" else 1))
crop_omx("allskims_H", taz.ZONEID, num_outfiles=(4 if segment_name == "full" else 1))

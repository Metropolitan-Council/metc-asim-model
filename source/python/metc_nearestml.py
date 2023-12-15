import pandana as pdna
from IPython.display import display
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
import geopandas as gpd
import argparse

def get_nodes(sf):
    sf['coord'] = sf['geometry'].apply(lambda x: x.coords[0]) 
    sf['x'] = sf['geometry'].apply(lambda x: x.coords[0][0]) 
    sf['y'] = sf['geometry'].apply(lambda x: x.coords[0][1]) 
    return(sf)
        
def get_links(sf):
    linksDict = {}
    outputD = []
    sf['first_coord'] = sf['geometry'].apply(lambda x: x.coords[0])
    sf['last_coord'] = sf['geometry'].apply(lambda x: x.coords[-1])
    # sf = sf.merge(nodes[['coord', 'ID']].rename(columns = {'ID': 'FROM_ID'}), how = 'left', left_on = 'first_coord', right_on = 'coord')
    # sf = sf.merge(nodes[['coord', 'ID']].rename(columns = {'ID': 'TO_ID'}), how = 'left', left_on = 'last_coord', right_on = 'coord')
    
    if 'coord_x' in sf.columns:
        sf.drop(columns = 'coord_x', inplace = True)
    if 'coord_y' in sf.columns:
        sf.drop(columns = 'coord_y', inplace = True)
    return(sf)

def run_nearest_managed_lane(link_file_name, node_file_name, zones, output_file_name):
    node_shape = gpd.read_file(node_file_name)
    link_shape = gpd.read_file(link_file_name)
    nodes = get_nodes(node_shape)
    links = get_links(link_shape)
    nodes.set_index('N', inplace = True)
    hov_node_list = pd.DataFrame({'N': pd.concat([links[(links['A'] > zones) & (links['B'] > zones) & (links['HOV'] != 0)]['A'], links[(links['A'] > zones) & (links['B'] > zones) & (links['HOV'] != 0)]['B']])}).merge(nodes[['x', 'y']], how = 'left', left_on = 'N', right_index = True)

    mcnet = pdna.Network(nodes.x, nodes.y, links["A"], links["B"], links[["DISTANCE"]])
    mcnet.precompute(50)
    mcnet.set_pois("hov", 200, 10, hov_node_list['x'], hov_node_list['y'])

    centroids = mcnet.get_node_ids(nodes.loc[1:zones]['x'], nodes.loc[1:zones]['y'])
    nearest_ml = pd.DataFrame({'zone_id': np.arange(1, zones + 1), 'ML_DIST': mcnet.nearest_pois(200, "hov", num_pois = 1).loc[1:zones][1]})
    nearest_ml.to_csv(output_file_name, index = False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog='preprocessor')
    parser.add_argument(
        '-l', '--link_shp_file',
        action = 'store', 
        help = 'Link Shape file',
        required = True)
    parser.add_argument(
        '-n' , '--node_shp_file',
        action = 'store', 
        help = 'Node Shape file',
        required = True)
    parser.add_argument(
        '-z', '--num_zones',
        action = 'store',
        help = 'Highest Zone Number',
        required = True)
    parser.add_argument(
        '-o' , '--output_file',
        action = 'store', 
        help = 'Output file',
        required = True)

    args = parser.parse_args()

    try:
        zones = int(args.num_zones)
    except (TypeError, ValueError):
        print("Zones value (-z / --num_zones) cannot be converted to an integer. Pls fix.")
    
    run_nearest_managed_lane(args.link_shp_file, args.node_shp_file, int(args.num_zones), args.output_file)
    
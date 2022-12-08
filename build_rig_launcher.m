% read json
close all;
clear;
cd ./

mesh_name = "bingby";
rig_name = "lbs_rig";

rig_data_dir = strcat(".\data\", mesh_name, "\",  rig_name, "\")
mkdir(rig_data_dir)

[V, F] =readOBJ(strcat(".\data\", mesh_name, "\", mesh_name,  ".obj"));
V = V(:, 1:2) %ensure 2D
build_rig(V, F, mesh_name, rig_name, strcat(".\data\", mesh_name, "\"));
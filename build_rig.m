function build_rig(V, F, mesh_name, rig_name, raw_data_dir)
    close all;
    fprintf( ...
        ['Make a LBS rig: \n' ...
        '- CLICK on mesh to add handle \n', ...
        '- PRESS w to compute weights\n', ...
        '- CLICK on handle to view weight for handle \n'...
        '- PRESS s to save rest parameters,weights, and mesh\n'] ...
        );



   %[V, mesh_scale, mesh_center] = scale_and_center_mesh(V(:, 1:2), 1, [0, 0]);
    W = [];
    obj_filename = strcat(raw_data_dir, "/", rig_name , "/", mesh_name, ".obj");
    weight_filename = strcat(raw_data_dir, "/", rig_name, "/W.DMAT");
    p0_filename = strcat(raw_data_dir, "/", rig_name, "/p0.DMAT");
    C_filename = strcat(raw_data_dir, "/", rig_name, "/C.DMAT");
    mkdir(strcat(weight_filename, "/../"));
    
    %save OBJ here.
    V2 = V;
    figure();
    hold on;
    t = tsurf(F, V);
    t.ButtonDownFcn = @onmeshdown;
    C = [];
    s = scatter3( ...
       [],[],[], ...
        'o','MarkerFaceColor',[0.9 0.8 0.1], 'MarkerEdgeColor','k',...
        'LineWidth',2,'SizeData',100, ...
        'ButtonDownFcn',@oncontrolsdown);
    set(gcf,'KeyPressFcn',@onkeypress)
    axis equal;
    hold off;

    function onmeshdown(src, ev)
        down_pos=get(gca,'currentpoint');
        V = src.Vertices(:, 1:2);

        V = [V; down_pos(1, 1:2)];
        E = boundary_faces(src.Faces);

        [V, F] = triangulate(V(:, 1:2), E, 'Flags', '-q20D');
        

        C = [C; down_pos(1, 1:2)];
        hold on;
        t = tsurf(F, V, 'FaceLighting','phong', 'FaceColor','interp' );
        t.ButtonDownFcn = @onmeshdown;
        s = scatter( ...
                   C(:, 1), C(:, 2), ...
                    'o','MarkerFaceColor',[0.9 0.8 0.1], 'MarkerEdgeColor','k',...
                    'LineWidth',2,'SizeData',100, ...
                    'ButtonDownFcn',@onhandledown);
        drawnow;
        hold off;
    
    end;
    
    function onkeypress(src, ev)
        if(strcmp(ev.Character,'w'))
          %find closest point on mesh for each handle, nothing too f
           bI = dsearchn(V, C);
           bc = speye(size(bI, 1));
           W = biharmonic_bounded(V, F, bI, bc);
           
           t.CData = W(:, 1);
        end;
        if (strcmp(ev.Character, 's'))
             writeOBJ(obj_filename,V, F);
             p0 = parameters_from_positions(C);
             writeDMAT(p0_filename, p0);
             writeDMAT(weight_filename, W);
             writeDMAT(C_filename, C);
        end

    end

    function onhandledown(src, ev)
         down_pos=get(gca,'currentpoint');
         p = down_pos(1, 1:2);
         I = dsearchn(C, p);
         t.CData = W(:, I);
    end
end
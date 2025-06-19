function ret = prepareForTarget3D(pursuit, data, ifi, NumSubframes)
    s_az = deg2rad(data(2,:)/NumSubframes);
    s_el = deg2rad(data(3,:)/NumSubframes);
    start_dist  = data(4,:)/NumSubframes;  
    e_az = deg2rad(data(5,:)/NumSubframes);
    e_el = deg2rad(data(6,:)/NumSubframes);
    end_dist  = data(7,:)/NumSubframes;
    velocity = data(8,:)/NumSubframes;

    if pursuit      % distance = direct line from fly's eye
        s1 =  abs(start_dist.*cos(s_el));
        e1 =  abs(end_dist.*cos(e_el));
        target_start = [s1.*sin(s_az); start_dist.*sin(s_el); -s1.*cos(s_az)];
        target_end = [e1.*sin(e_az); end_dist.*sin(e_el); -e1.*cos(e_az)];
    else            % distance = Z "depth" of XY plane from fly's eye
        target_start = [start_dist.*tan(s_az); start_dist.*tan(s_el); -start_dist];
        target_end = [end_dist.*tan(e_az); end_dist.*tan(e_el); -end_dist];
    end
    
    target_distances = sqrt(sum((target_end-target_start).^2));
    ret.target_start = target_start;
    ret.target_end = target_end;
    ret.num_frames = floor(target_distances ./ (velocity.*ifi));
end
function ret = prepareForTarget3DYuri(pursuit, data, ifi, NumSubframes)
%     s_az = deg2rad(data(2,:)/NumSubframes);
%     s_el = deg2rad(data(3,:)/NumSubframes);
%     start_dist  = data(4,:)/NumSubframes;  
%     e_az = deg2rad(data(5,:)/NumSubframes);
%     e_el = deg2rad(data(6,:)/NumSubframes);
%     end_dist  = data(7,:)/NumSubframes;
    
    
x = data(2,:)/NumSubframes;
y = data(3,:)/NumSubframes;
z = data(4,:)/NumSubframes;
framerate = data(5,:)/NumSubframes;

%     if pursuit      % distance = direct line from fly's eye
%         s1 =  abs(start_dist.*cos(s_el));
%         e1 =  abs(end_dist.*cos(e_el));
%         target_start = [s1.*sin(s_az); start_dist.*sin(s_el); -s1.*cos(s_az)];
%         target_end = [e1.*sin(e_az); end_dist.*sin(e_el); -e1.*cos(e_az)];
%     else            % distance = Z "depth" of XY plane from fly's eye
        target_pos = [x; y; z];
%         target_end = [end_x; end_y; end_z];
%     end
    
%     target_distances = sqrt(sum((target_end-target_start).^2));
    ret.target_start = target_pos;
    ret.target_end = target_pos;
%     ret.num_frames = floor(target_distances ./ (velocity.*ifi));
    ret.num_frames = framerate;
  
end
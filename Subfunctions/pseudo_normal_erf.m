function values = pseudo_normal_erf(mu, sigma, N)
    % Create a range over which we calculate boundary points.
    % The values we return will be the midpoints of the segments between
    % boundary points.
    % The probability of each segment should be equal
    % (because we want there to be exactly one point in each segment).
    % Hence we can use norminv over a linear probability space.
    % We ask for N + 3 points, because we need one more boundary point than
    % the number of segments, and we will discard 0 and 1 (as they are +-Inf).
    
    range = linspace(0, 1, N+3);    
    boundaries = -sqrt(2).*erfcinv(2*range);

    boundaries = boundaries(2:end-1); % discard 0 and 1
    values = (boundaries(1:end-1) + boundaries(2:end))/2; % get midpoints

    values = mu + sigma*values; % scale and shift appropriately
    values = values(randperm(N));   % shuffle
end
function values = pseudo_normal(mu, sigma, N)
    % Create a range over which we calculate boundary points.
    % The values we return will be the midpoints of the segments between
    % boundary points.
    % The probability of each segment should be equal
    % (because we want there to be exactly one point in each segment).
    % Hence we can use norminv over a linear probability space.
    % We ask for N + 3 points, because we need one more boundary point than
    % the number of segments, and we will discard 0 and 1 (as they are +-Inf).

    values = randn(1, N);
    values = mu + sigma*values; % scale and shift appropriately
end
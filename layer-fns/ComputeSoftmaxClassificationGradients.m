% Want to distribute this code? Have other questions? -> sbowman@stanford.edu
function [ matrixGradients, deltaDown ] = ...
    ComputeSoftmaxClassificationGradients(matrix, probs, labels, in, hyperParams, multipliers)
% Compute the gradient for the softmax layer parameters assuming log loss for a batch.

B = size(probs, 2);
inPadded = [ones(1, B); in];
matrixGradients = zeros(size(matrix, 1), size(matrix, 2), B);

% Compute a nonzero target relations vector for only those batch entries that have nonzero
% target relations.
dataPointHasLabel = labels(:, 1) ~= 0;
fullRange = 1:size(labels, 1);
filteredRange = fullRange(dataPointHasLabel);
targetprobs = zeros(size(probs, 1), size(probs, 2));

% TODO: Speed up... oddly slow.
targetprobs(sub2ind(size(probs), labels(dataPointHasLabel, 1), filteredRange')) = 1;

if size(labels, 2) == 2
	% Multiple class set case.

	for b = 1:B
		relationRange = hyperParams.relationRanges{labels(b, 2)};
		delta = probs(1:length(relationRange), b) - targetprobs(1:length(relationRange), b);
		if nargin > 5
			% Scale the deltas by the multipliers (optional)
			delta = delta .* multipliers(b);
		end

		if ~isempty(matrix)
			if dataPointHasLabel(b)
				matrixGradients(relationRange, :, b) = delta * inPadded(:, b)';
			end
			deltaDown(:, b) = matrix(relationRange, :)' * delta;
		else
			deltaDown(:, b) = delta;
		end
	end
else
	if nargin > 5
		% Scale the delatas by the multipliers (optional)		
		delta = bsxfun(@times, (probs - targetprobs), dataPointHasLabel' .* multipliers');
	else
		delta = bsxfun(@times, (probs - targetprobs), dataPointHasLabel');
	end

	if ~isempty(matrix)
		matrixGradients = delta * inPadded';
		deltaDown = matrix' * delta;
	else
		deltaDown = delta;
	end
end

if ~isempty(matrix)
	% Remove bias deltas.
	deltaDown = deltaDown(2:end, :);
end

end

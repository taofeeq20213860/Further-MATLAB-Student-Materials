function tests = test_fitQuadModel()
    % Test array constructed from local functions in this file
    tests = functiontests( localfunctions() );
end

function setupOnce(testCase)
    addpath('./Test_Data');
    testCase.TestData = load('fitQuadModel_TestData.mat');
    testCase.TestData.currentRNG = rng;
end

function test_nargin(testCase)
% fitQuadModel should throw an exception when called ...
% with 0, 1 or 4 or more input arguments;
verifyError(testCase, @() fitQuadModel(),'MATLAB:narginchk:notEnoughInputs')
verifyError(testCase, @() fitQuadModel(0),'MATLAB:narginchk:notEnoughInputs')
verifyError(testCase, @() fitQuadModel(1,2,3,4), 'MATLAB:TooManyInputs')
end % test_nargin

function test_invalidInputs(testCase)
rng('default');
% the first input argument, X, is a real, 2D, nonempty double matrix with no infinite values;
verifyError(testCase,@() fitQuadModel( rand(10,0), rand(10,1)), ...
   'MATLAB:fitQuadModel:expectedNonempty');
verifyError(testCase, @() fitQuadModel( Inf(10,1), rand(10,1)), ...
    'fitQuadModel:expectedNoninfinite')
% the second input argument, y, is a real, nonempty column vector of type double with no infinite values;
verifyError(testCase, @() fitQuadModel( rand(10,1), Inf(10,1)), ...
     'fitQuadModel:expectedNoninfinite')
% the third input argument, showplot, is a logical scalar value;
verifyError( testCase, @() fitQuadModel( rand(3,2), rand(3,1), true(1,2)), ...
    'MATLAB:fitQuadModel:expectedScalar')
% X has at least three rows and at most two columns;
verifyError( testCase, @() fitQuadModel(rand(2,2), rand(2,1)), ...
    'fitQuadModel:XTooSmall')
verifyError( testCase, @() fitQuadModel(rand(3,4), rand(3,1)), ...
    'fitQuadModel:TooManyXCols')
 
% the number of rows of X and y coincide.
verifyError( testCase, @() fitQuadModel(rand(3,2), rand(2,1)), ...
    'fitQuadModel:DimMismatch')

end % test_invalidInputs

function test_validOutputs(testCase)
rng('default');
% Test that values returned from function are doubles
verifyInstanceOf( testCase, fitQuadModel( rand(30,1), rand(30,1)), 'double');
verifyInstanceOf( testCase, fitQuadModel( rand(30,2), rand(30,1)), 'double');

% Test that returned data is correct size
c = fitQuadModel(rand(100,1), rand(100,1));
verifySize( testCase, c,[3,1]);
c = fitQuadModel(rand(100,2), rand(100,1));
verifySize( testCase, c,[6,1]);
end

function test_basicFit(testCase)
    x = testCase.TestData.X1;
    y = testCase.TestData.y1;
    cExpected = testCase.TestData.c1;
    cActual = fitQuadModel(x,y);
    verifyEqual(testCase, cActual, cExpected, 'AbsTol', 1e-10);
    
    x = testCase.TestData.X2;
    y = testCase.TestData.y2;
    cExpected = testCase.TestData.c2;
    cActual = fitQuadModel(x, y);
    verifyEqual(testCase, cActual, cExpected, 'AbsTol', 1e-10)
    
    % Test the function against another solution method (LINSOLVE).
    rng('default')
    x1 = rand(500, 1); x2 = rand(500, 1);
    y = rand(500, 1);
    A = [ones(size(x1)), x1, x2, x1.^2, x2.^2, x1.*x2];
    c_linsolve = linsolve(A, y);
    cActual = fitQuadModel([x1, x2], y);
    verifyEqual(testCase, cActual, c_linsolve, 'AbsTol', 1e-10)
    
    % Test the function against another solution method (POLYFIT).
    rng('default')
    x = rand(500, 1);
    y = 15 + 4*x - 7*x.^2 + randn(size(x));
    c_polyfit = polyfit(x, y, 2);
    c_polyfit = flipud( c_polyfit.' );
    cActual = fitQuadModel(x, y);
    verifyEqual(testCase, cActual, c_polyfit, 'AbsTol', 1e-10)
end

function test_allNaNs(testCase)
rng('default')
x = rand(10,1);
y = NaN(10,1);
verifyError(testCase, @() fitQuadModel(x,y), 'fitQuadModel:AllNaNs')
end

function teardownOnce(testCase)
    rmpath('./Test_Data')
    s = testCase.TestData.currentRNG;
    rng(s);
end
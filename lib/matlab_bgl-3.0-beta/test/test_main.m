function test_main
%% Implement a test suite for matlab_bgl
% Call this function to test the MatlabBGL package.

%% Setup some parameters

msgid = 'matlab_bgl:test_main';

%% Test functions on empty or trivial input
% The goal of these tests is to make sure we get error messages or 
% reasonable output (i.e. it doesn't crash) on somewhat malformed or
% trivial input.

% test functions on empty matrices
try
    d = bfs(sparse([]),0);
    error(msgid, 'bfs did not report error');
catch 
end

try
    d = dfs(sparse([]),0);
    error(msgid, 'dfs did not report error');
catch 
end

try
    d = astar_search(sparse([]),0,@(x) x);
    error(msgid, 'astar_search did not report error');
catch 
end

try
    d = shortest_paths(sparse([]), 0);
    error(msgid, 'shortest_paths did not report error');
catch 
end

try
    d = bellman_ford_sp(sparse([]), 0);
    error(msgid, 'bellman_ford_sp did not report error');
catch 
end

try
    d = dag_sp(sparse([]), 0);
    error(msgid, 'dag_sp did not report error');
catch 
end

try
    f = max_flow(sparse([]),0,0);
    error(msgid, 'max_flow did not report error');
catch 
end

try
    p = dominator_tree(sparse([]),0);
    error(msgid, 'lengauer_tarjan_dominator_tree did not report error');
catch 
end

D = johnson_all_sp(sparse([]));
D = all_shortest_paths(sparse([]));
D = floyd_warshall_all_sp(sparse([]));
T = mst(sparse([]));
T = kruskal_mst(sparse([]));
T = prim_mst(sparse([]));
cc = components(sparse([]));
bcs = biconnected_components(sparse([]));
c = betweenness_centrality(sparse([]));
c = clustering_coefficients(sparse([]));
ei = edge_weight_index(sparse([]));
m = matching(sparse([]));
m = core_numbers(sparse([]));

%% Code examples

% all_shortest_paths
load('../graphs/clr-26-1.mat');
all_shortest_paths(A);
all_shortest_paths(A,struct('algname','johnson'));

% astar_search
load('../graphs/bgl_cities.mat');
goal = 11; % Binghamton
start = 9; % Buffalo
% Use the euclidean distance to the goal as the heuristic
h = @(u) norm(xy(u,:) - xy(goal,:));
% Setup a routine to stop when we find the goal
ev = @(u) (u ~= goal);
[d pred f] = astar_search(A, start, h, ...
    struct('visitor', struct('examine_vertex', ev)));

% bellman_ford
load('../graphs/kt-6-23.mat');
d = bellman_ford_sp(A,1);

% betweenness_centrality
load('../graphs/padgett-florentine.mat');
betweenness_centrality(A);

% bfs
load('../graphs/bfs_example.mat');
d = bfs(A,1);

% biconnected_components
load('../graphs/tarjan-biconn.mat');
biconnected_components(A);

% breadth_first_earch
% see (dist_uv_bfs below)    
load('../graphs/bfs_example.mat');
d2 = dist_uv_bfs(A,1,3);

% clustering_coefficients
load('../graphs/clique-10.mat');
clustering_coefficients(A);

% combine_visitors

% components
load('../graphs/dfs_example.mat');
components(A);
     
% core_numbers
load('../graphs/cores_example.mat');
cn = core_numbers(A);

% cycle_graph
[A xy] = cycle_graph(10);
gplot(A,xy);

% dag_sp
load('../graphs/kt-3-7.mat');
dag_sp(A,1);

% depth_first_search

% dfs
% dijkstra_sp
% edge_weight_index
% erdos_reyni
% floyd_warshall_all_sp
% indexed_sparse
% johnson_all_sp
% kruskal_mst

% lengauer_tarjan_dominator_tree
load('../graphs/dominator_tree_example.mat');
p = lengauer_tarjan_dominator_tree(A,1);

% matching
load('../graphs/matching_example.mat');
[m,v] = matching(A);
[m,v] = matching(A,struct('augmenting_path','none'));

% max_flow
% mst
% num_edges
% num_vertices

% path_from_pred
load('../graphs/bfs_example.mat');
[d dt pred] = bfs(A,1,struct('target', 3));
path = path_from_pred(pred,3); % sequence of vertices to vertex 3

% prim_mst
load('../graphs/clr-24-1.mat');
prim_mst(A);

% shoretst_paths
load('../graphs/clr-25-2.mat');
shortest_paths(A,1);
shortest_paths(A,1,struct('algname','bellman_ford'));

% star_graph
[A xy] = star_graph(10);
gplot(A,xy);

% test_dag
n = 10; A = sparse(1:n-1, 2:n, 1, n, n); % construct a simple dag
test_dag(A);
A(10,1) = 1; % complete the cycle
test_dag(A);

% toplogical_order
load('../graphs/bfs_example.mat');
d = bfs(A,1);

% test_matching
load('../graphs/matching_example.mat');
[m_not_max,v] = matching(A,struct('augmenting_path','none'));
test_matching(A,m_not_max);

% tree_from_pred

% wheel graph
[A xy] = wheel_graph(10);
gplot(A,xy);
n = 10;
A = cycle_graph(n);
[d dt ft pred] = dfs(A,1,struct('target',3));

%% all_shortest_paths

%% astar_search

%% betweenness_centrality

n = 10;
A = cycle_graph(n);

% the centrality index of all vertices in a cycle is the same
bc = betweenness_centrality(A,struct('unweighted',1));
if any(bc-bc(1))
    error(msgid, 'betweenness_centrality returned incorrect values for a cycle');
end

% make sure we toss an error when the graph has logical weights
try 
    bc = betweenness_centrality(A);
    error(msgid, 'betweenness_centrality did not report an error');
catch
end

% make sure the edge centrality graphs are the same in a few cases
A = sparse(1:n-1, 2:n, 1, n, n);
[bc,Ec] = betweenness_centrality(A);
if any(any(spones(A) - spones(Ec)))
    error(msgid, 'different non-zero structure in edge centrality matrix');
end

[bc,Ec] = betweenness_centrality(A,struct('istrans',1));
if any(any(spones(A) - spones(Ec)))
    error(msgid, 'different non-zero structure in edge centrality matrix');
end

% make sure betweenness centrality can use an optional edge weight matrix
bc = betweenness_centrality(A,struct('edge_weight',rand(nnz(A),1)));
bc = betweenness_centrality(A);
bc2 = betweenness_centrality(A,struct('edge_weight','matrix'));
if any(bc-bc2)
    error(msgid, 'edge_weight option error');
end
try
    bc = betweenness_centrality(A,struct('edge_weight',rand(2,1)));
    error(msgid, 'betweenness_centrality did not report an error');    
catch
end

%% biconnected_components

%% bfs

%% breadth_first_search

%% clustering_coefficients

% Create a clique, where all the clustering coefficients are equal
A = sparse(ones(5));
ccfs = clustering_coefficients(A);
if any(ccfs ~= ccfs(1))
    error(msgid, 'clustering_coefficients failed');
end

%% core_numbers
load('../graphs/kt-7-2.mat');
A = spones(A);
cn = core_numbers(A);
load('../graphs/cores_example.mat');
cn = core_numbers(A);
cn2 = core_numbers(A,struct('unweighted',0));
if any(cn-cn2)
    error(msgid, 'core_numbers failed equivalence test');
end

A = [0 -1 -2; -1 0 -2; -2 -2 0];
cn = core_numbers(sparse(A),struct('unweighted',0));
if any(cn-[-1; -1; -4])
    error(msgid, 'core_numbers failed negative test');
end

%% dfs

%% dominator_tree
load('../graphs/dominator_tree_example.mat');
p = lengauer_tarjan_dominator_tree(A,1);
if any(p ~= [ 0, 1,  2,  2,  4,   5,  5,  2])
    error(msgid, 'lengauer_tarjan_dominator_tree failed test');
end

% graphs from boost example's

A=sparse(13,13);
A(1,2)=1;A(1,3)=1;A(1,4)=1;A(2,5)=1;A(3,2)=1;A(3,5)=1;A(3,6)=1;A(4,7)=1;
A(4,8)=1;A(5,13)=1;A(6,9)=1;A(7,10)=1;A(8,10)=1;A(8,11)=1;A(9,6)=1;
A(9,12)=1;A(10,12)=1;A(11,10)=1;A(12,1)=1;A(12,10)=1;A(13,9)=1;
pred=[0 1 1 1 1 1 4 4 1 1 8 1 5 ];
p = lengauer_tarjan_dominator_tree(A,1);
if any(p ~= pred)
   error(msgid, 'lengauer_tarjan_dominator_tree failed test');
end

A=sparse(7,7);
A(1,2)=1;A(2,3)=1;A(2,4)=1;A(3,5)=1;A(3,6)=1;A(5,7)=1;A(6,7)=1;A(7,2)=1;
pred=[0 1 2 2 3 3 3 ];
p = lengauer_tarjan_dominator_tree(A,1);
if any(p ~= pred)
   error(msgid, 'lengauer_tarjan_dominator_tree failed test');
end

A=sparse(13,13);
A(1,2)=1;A(1,3)=1;A(2,4)=1;A(2,7)=1;A(3,5)=1;A(3,8)=1;A(4,6)=1;A(4,7)=1;
A(5,8)=1;A(5,3)=1;A(6,9)=1;A(6,11)=1;A(7,10)=1;A(8,13)=1;A(9,12)=1;
A(10,9)=1;A(11,12)=1;A(12,2)=1;A(12,13)=1;
pred=[0 1 1 2 3 4 2 3 2 7 6 2 1 ];
p = lengauer_tarjan_dominator_tree(A,1);
if any(p ~= pred)
   error(msgid, 'lengauer_tarjan_dominator_tree failed test');
end

A=sparse(8,8);
A(1,2)=1;A(2,3)=1;A(2,4)=1;A(3,8)=1;A(4,5)=1;A(5,6)=1;A(5,7)=1;A(6,8)=1;
A(7,5)=1;
pred=[0 1 2 2 4 5 5 2 ];
p = lengauer_tarjan_dominator_tree(A,1);
if any(p ~= pred)
   error(msgid, 'lengauer_tarjan_dominator_tree failed test');
end

A=sparse(8,8);
A(1,2)=1;A(2,3)=1;A(3,4)=1;A(3,5)=1;A(4,3)=1;A(5,6)=1;A(5,7)=1;A(6,8)=1;
A(7,8)=1;
pred=[0 1 2 3 3 5 5 5 ];
p = lengauer_tarjan_dominator_tree(A,1);
if any(p ~= pred)
   error(msgid, 'lengauer_tarjan_dominator_tree failed test');
end

A=sparse(8,8);
A(1,2)=1;A(1,3)=1;A(2,7)=1;A(3,4)=1;A(3,5)=1;A(4,8)=1;A(6,8)=1;A(7,8)=1;
pred=[0 1 1 3 3 0 2 1 ];
p = lengauer_tarjan_dominator_tree(A,1);
if any(p ~= pred)
   error(msgid, 'lengauer_tarjan_dominator_tree failed test');
end

A=sparse(14,14);
A(1,2)=1;A(1,14)=1;A(2,3)=1;A(3,4)=1;A(3,8)=1;A(4,5)=1;A(4,6)=1;A(5,7)=1;
A(6,7)=1;A(7,9)=1;A(8,9)=1;A(9,10)=1;A(10,11)=1;A(10,12)=1;A(11,12)=1;
A(12,10)=1;A(12,13)=1;A(13,3)=1;A(13,14)=1;
pred=[0 1 2 3 4 4 4 3 3 9 10 10 12 1 ];
p = lengauer_tarjan_dominator_tree(A,1);
if any(p ~= pred)
   error(msgid, 'lengauer_tarjan_dominator_tree failed test');
end



%% edmonds_maximum_cardinality_matching
load('../graphs/matching_example.mat');
[m,v] = edmonds_maximum_cardinality_matching(A);
if nnz(m)/2 ~= 8
    error(msgid, 'edmonds_maximum_cardinality_matching failed');
end

%% matching
load('../graphs/dfs_example.mat');
try
    [m,v] = matching(A);
    error(msgid,'matching failed');
catch
end
load('../graphs/matching_example.mat');
[m,v] = matching(A);

%% max_flow

%% mst

%% pred_from_path

% Create a line graph
n = 10;
A = sparse(1:n-1,2:n,1,n,n);
A = A+A';

% Compute BFS and test pred_from_path
[d dt pred] = bfs(A,1);
path = path_from_pred(pred,n);
if any(path ~= 1:n)
    error(msgid, 'path_from_pred failed');
end


%% shortest_paths

%% test_dag
% Test the dag_test function, which also tests topological order
A = sparse(6,6);
A(3,6) = 1;
A(1,2) = 1;
A(3,5) = 1;
A(1,4) = 1;
A(2,5) = 1;
A(5,4) = 1;

dag = test_dag(A);
if dag == 0
    error(msgid, 'A dag was not identified as a dag');
end

% Test something that isn't a dag
A = cycle_graph(n);

dag = test_dag(A);
if dag == 1
    error(msgid, 'A cycle was identified as a dag');
end

%% test_matching
load('../graphs/matching_example.mat');
[m_max,v] = matching(A);
[m_not_max,v] = matching(A,struct('augmenting_path','none'));
if ~test_matching(A,m_max) || test_matching(A,m_not_max)
    error(msgid, 'test_matching failed');
end

%% topological_order
% Test the topological order function
n = 10;
A = sparse(1:n-1, 2:n, 1, n, n);
p = topological_order(A);
if any(p - (1:n)')
    error(msgid, 'topological_order failed on simple case');
end



%%
% ***** end test_main *****
end


%% Accessory functions

    function dv=dist_uv_bfs(A,u,v)
      vstar = v;
      dmap = ipdouble(zeros(size(A,1),1));
      function stop=on_tree_edge(ei,u,v)
        dmap(v) = dmap(u)+1;
        stop = (v ~= vstar);
      end
      breadth_first_search(A,u,struct('tree_edge',@on_tree_edge));
      dv = dmap(v);
    end

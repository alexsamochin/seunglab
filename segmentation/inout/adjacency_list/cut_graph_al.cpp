#include <stdio.h>
#include "graph.h"
#include "mex.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  int num_nodes;
  int i;
  double *sink_source_matrix;
  double *adjacent_node_matrix;
  int num_adj_edges;

  int should_be_2;
  int should_be_4;
  
  double *outArray;


  /* Check for proper number of arguments. */
  if(nrhs!=2) {
    mexErrMsgTxt("Two input arguments required - adjacent_node_matrix and sink_source_node_matrix");
  } else if(nlhs>1) {
    mexErrMsgTxt("Should have one output for labels of each node");
  }


  //get the sink_source matrix
  sink_source_matrix = mxGetPr(prhs[0]);
  num_nodes = mxGetM(prhs[0]);
  
  should_be_2 = mxGetN(prhs[0]);
  if(should_be_2 !=2) 
    mexErrMsgTxt("sink_source_matrix must have exactly 2 columns.");



  //get adjacent_node_matrix
  adjacent_node_matrix = mxGetPr(prhs[1]);
  num_adj_edges = mxGetM(prhs[1]);
 

  should_be_4 = mxGetN(prhs[1]);
  if(should_be_4 !=4) 
    mexErrMsgTxt("adjacent_node_matrix must have exactly 4 columns.");



  
  //  Graph::node_id nodes[num_nodes];
  // allocate memory from MATLAB heap - otherwise we'll get a segfault for too big arrays
  Graph::node_id *nodes = (Graph::node_id *)mxMalloc(num_nodes*sizeof(Graph::node_id));

  Graph *g = new Graph();

   printf("args6\n");

  //  printf("adding nodes");

  //add nodes to graph, and set weights between nodes and sources and sinks
  for(i = 0; i < num_nodes; i++) 
  {
    //    printf("%d %d\n",num_nodes,i);

    nodes[i] = g -> add_node();
    g -> set_tweights(nodes[i], (int) sink_source_matrix[i], ( int) sink_source_matrix[i + num_nodes]);

    //    printf("%d \n",(int)sink_source_matrix[i]);
 
    //printf("curr val: %d\n", (short int) sink_source_matrix[i + num_nodes]);

  }

  //  printf("adding edges");
  //set the weights between nodes
  for (i = 0; i < num_adj_edges; i++)
  {
     int i1= ( int) adjacent_node_matrix[i] - 1;
     int i2= (int) adjacent_node_matrix[i + num_adj_edges] - 1;
     int i3= ( int) adjacent_node_matrix[i + 2* num_adj_edges];
     int i4= ( int) adjacent_node_matrix[i + 3* num_adj_edges];
     //    printf("%d\n",i4); 
//      printf("%d %d ",i,num_nodes); 
//      printf("%d ",i1); 
//      printf("%d ",i2);
//      printf("%d ",i3);
//     printf("%d\n",i4); 


     g -> add_edge(nodes[i1], nodes[i2],i3 ,i4);


    //printf("adj vals: %d %d \n", (short int) (adjacent_node_matrix[i] - 1), (short int) (adjacent_node_matrix[i + 3 * num_adj_edges]));

  }

  //  printf("done - do flow ");
  
  //do the graph-cut 
  Graph::flowtype flow = g -> maxflow();
  printf("Flow = %d\n", flow);
  //printf("Minimum cut:\n");


  

  //create output - Allocate memory and assign output pointer
  plhs[0] = mxCreateDoubleMatrix(num_nodes, 1, mxREAL); //mxReal is our data-type
  outArray = mxGetPr(plhs[0]);    //Get a pointer to the data space in our newly allocated memory

  for (i = 0; i < num_nodes; i++)
  {
    if (g->what_segment(nodes[i]) == Graph::SOURCE)
      outArray[i] = 1;
    else if (g->what_segment(nodes[i]) == Graph::SINK)
      outArray[i] = 0;
    else
      outArray[i] = -1;
  }

  mxFree(nodes);

  delete g;

}







//4. Example usage.
//This section shows how to use the library to compute
//a minimum cut on the following graph:
//
//		        SOURCE
///		       /       \
//		     1/         \2
//		     /      3    \
//		   node0 -----> node1
//		     |   <-----   |
//		     |      4     |
//		     \            /
//		     5\          /6
//		       \        /
//		          SINK
//
///////////////////////////////////////////////////

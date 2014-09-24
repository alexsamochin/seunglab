#include "mex.h"
#include <iostream>
#include <cstdlib>
#include <boost/pending/disjoint_sets.hpp>
#include <vector>
#include <queue>
#include <set>
#include <map>
#include <cmath>
#include <unistd.h>
#include <time.h>
#include "boost/tuple/tuple.hpp"
using namespace std;

// zero-based sub2ind
mwSize sub2ind(
		const mwSize * sub,
		const mwSize num_dims,
		const mwSize * dims
		)
{
	mwSize ind = 0;
	mwSize prod = 1;
	for (mwSize d=0; d<num_dims; d++) {
		ind += sub[d] * prod;
		prod *= dims[d];
	}
	return ind;
}

// zero-based ind2sub
void ind2sub(
		mwSize ind,
		const mwSize num_dims,
		const mwSize * dims,
		mwSize * sub
		)
{
	for (mwSize d=0; d<num_dims; d++) {
		sub[d] = (ind % dims[d]);
		ind /= dims[d];
	}
	return;
}

mwSize distance (const mwSize * v1, const mwSize * v2, mwSize dims){
	mwSize euc=0;
	for (mwSize dim=0; dim<dims; dim++){
		euc += (v1[dim]-v2[dim])*(v1[dim]-v2[dim]);
	}
	return sqrt(euc);
}


class mycomp{
    const float * conn_data;
    public:
        mycomp(const float * conn_data_param){
            conn_data = conn_data_param;
        }
        bool operator() (const mwSize& ind1, const mwSize& ind2) const {
            return conn_data[ind1]<conn_data[ind2];
        }
};
    
class setcomp{

    public:

    bool operator() (std::pair<mwSize,mwSize> p1, std::pair<mwSize, mwSize> p2) const 
    {
	if (p1.second==p2.second){
		return p1.first < p2.first;
	}
        return p1.second < p2.second;
    }
};

class classcomp{

    public:

    bool operator() (std::pair<std::pair <float, float>, float> p1, std::pair<std::pair <float, float>, float> p2) const 
    {	if (p1.second==p2.second){
		return (p1.first).first < (p2.first).first;
	}
        return p1.second > p2.second;
    }
};

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    const mxArray * conn = prhs[0];
	const mwSize conn_num_dims = mxGetNumberOfDimensions(conn);
	const mwSize * conn_dims = mxGetDimensions(conn);
	const mwSize conn_num_elements = mxGetNumberOfElements(conn);
	const float * conn_data =(const float *)mxGetData(conn);
	const mxArray * nhood = prhs[1];
	const mwSize nhood_num_dims = mxGetNumberOfDimensions(nhood);
	const mwSize * nhood_dims = mxGetDimensions(nhood);
	const double * nhood_data = (const double *)mxGetData(nhood);
	const double low_threshold = (const double) mxGetScalar(prhs[2]);
	
    if (!mxIsSingle(conn)){
        mexErrMsgTxt("Conn array must be floats (singles)");
    }
    if (nhood_num_dims != 2) {
		mexErrMsgTxt("wrong size for nhood");
	}
	if ((nhood_dims[1] != (conn_num_dims-1))
		|| (nhood_dims[0] != conn_dims[conn_num_dims-1])){
		mexErrMsgTxt("nhood and conn dimensions don't match");
	}
    

	mxArray * ws;
    mwSize ws_num_dims=conn_num_dims-1;
    mwSize ws_dims[ws_num_dims];
    for (mwSize i=0; i<ws_num_dims; i++){
        ws_dims[i]=conn_dims[i];
    }
    plhs[0]=mxCreateNumericArray(ws_num_dims, ws_dims, mxSINGLE_CLASS, mxREAL);
    if (plhs[0] == NULL) {
		mexErrMsgTxt("Unable to create output array");
		return;
	}
    ws=plhs[0];
    float * ws_data=(float *)mxGetData(ws);    
    mwSize num_vertices=mxGetNumberOfElements(ws);
    
	std::map<float,mwSize> components;
	std::set<float> comp_set;

	//cout << "num vertices : " << num_vertices << endl;


    for (mwSize i=0; i<num_vertices; i++){
        ws_data[i]=0;
    }

	std::vector<mwSize> rank(num_vertices);
    std::vector<mwSize> parent(num_vertices);
    boost::disjoint_sets<mwSize*, mwSize*> dsets(&rank[0],&parent[0]);
    for (mwSize i=0; i<num_vertices; i++){
        dsets.make_set(i);
    }


	std::priority_queue <mwSize, vector<mwSize>, mycomp > pqueue (conn_data);



    for (mwSize i=0; i<conn_num_elements; i++){
		if (conn_data[i]>low_threshold){
        	pqueue.push(i);
		}
    }

    mwSize cind=1;
    float inf=1;
    for (mwSize dims=0; dims<conn_num_dims; dims++){
        inf*=(float)conn_dims[dims];
    }
	inf++;

	//initialize dendrogram disjoint sets
  	std::vector<mwSize> rank1((mwSize)inf);
    std::vector<mwSize> parent1((mwSize)inf);
    boost::disjoint_sets<mwSize*, mwSize*> den_dsets(&rank1[0],&parent1[0]);
    for (mwSize i=0; i<num_vertices; i++){
        dsets.make_set(i);
    }


	std::vector < boost::tuple < float, float, float> > internal_dend;
	std::map<mwSize, float> parent_array;
	
	


	while(!pqueue.empty()){
		
		mwSize cur_edge=pqueue.top();


		pqueue.pop();
		mwSize edge_array[conn_num_dims];
        ind2sub(cur_edge,conn_num_dims,conn_dims,edge_array);
        mwSize v1, v2;
        mwSize v1_array[conn_num_dims-1], v2_array[conn_num_dims-1];
        for (mwSize i=0; i<conn_num_dims-1; i++){
            v1_array[i]=edge_array[i];
            v2_array[i]=edge_array[i];
        }
        for (mwSize i=0; i<nhood_dims[1]; i++){
            v2_array[i]+=nhood_data[nhood_dims[0]*i+edge_array[conn_num_dims-1]];
        }
        bool OOB=false;
        for (mwSize i=0; i<conn_num_dims-1; i++){
            if (v2_array[i]<0 || v2_array[i]>=conn_dims[i]){
                OOB=true;
            }
        }

        if (!OOB){
			v1=sub2ind(v1_array, conn_num_dims-1, conn_dims);
            v2=sub2ind(v2_array, conn_num_dims-1, conn_dims);
			mwSize set1=dsets.find_set(v1);
            mwSize set2=dsets.find_set(v2);

                if (ws_data[v1]==0 && ws_data[v2]==0){
                    ws_data[v1]=cind;
                    ws_data[v2]=cind;
                    dsets.link(set1, set2);
					//den_dsets.make_set(cind);
					parent_array[cind]=(float) cind;
                    cind++;
                }
                else if (ws_data[v2]==0 && ws_data[v1]!=0){
                    ws_data[v2]=ws_data[v1];
                    dsets.link(set1, set2);
                }
                else if (ws_data[v1]==0 && ws_data[v2]!=0){
                    ws_data[v1]=ws_data[v2];
                    dsets.link(set1, set2);
                }
				else if (ws_data[v1]!=0 && ws_data[v2]!=0){
					float label_of_set1 = ws_data[v1];
					float label_of_set2 = ws_data[v2];
					mwSize den_set1=den_dsets.find_set(label_of_set1);
					mwSize den_set2=den_dsets.find_set(label_of_set2);
					if (den_set1 != den_set2){
						float first=parent_array[(mwSize)den_dsets.find_set(label_of_set1)];
						float second = parent_array[(mwSize)den_dsets.find_set(label_of_set2)];
						internal_dend.push_back(boost::tuple < float, float, float> (first, second, conn_data[(mwSize)cur_edge]));
						den_dsets.link(den_set1, den_set2);
						parent_array[den_dsets.find_set(label_of_set1)]=inf;
						inf++;
						
					}
				}

            


		}
	}

	//write dendrogram output
	mxArray * thresh;
    mwSize thresh_num_dims=2;
    mwSize thresh_dims[thresh_num_dims];
	thresh_dims[0]=internal_dend.size();
	thresh_dims[1]=3;
    plhs[1]=mxCreateNumericArray(2, thresh_dims, mxSINGLE_CLASS, mxREAL);
    if (plhs[1] == NULL) {
		mexErrMsgTxt("Unable to create dendrogram");
		return;
	}
	cout << "got to this point" << endl;
	printf("got to this point also\n");

    thresh=plhs[1];
    float * thresh_data=(float *)mxGetData(plhs[1]);    
    mwSize thresh_elements=mxGetNumberOfElements(thresh);

	mwSize place=0;
	std::vector<boost::tuple <float, float, float> >::iterator internal_dend_it;
	//cout << "map size is " << sorted_map.size() << endl;
	for (internal_dend_it=internal_dend.begin(); internal_dend_it!=internal_dend.end(); internal_dend_it++){


		boost::tuple <float, float, float> tuple= *internal_dend_it;

		mwSize fst_pair[2];
		fst_pair[0]=place;
		fst_pair[1]=2;
		mwSize fst_loc=sub2ind(fst_pair, 2, thresh_dims);
		thresh_data[fst_loc]=tuple.get<2>();



		mwSize trd_pair[2];
		trd_pair[0]=place;
		trd_pair[1]=0;
		mwSize trd_loc=sub2ind(trd_pair, 2, thresh_dims);

		thresh_data[trd_loc]=tuple.get<0>();


		mwSize fth_pair[2];
		fth_pair[0]=place;
		fth_pair[1]=1;
		mwSize fth_loc=sub2ind(fth_pair, 2, thresh_dims);

		thresh_data[fth_loc]=tuple.get<1>();


		place++;
	

	}
}



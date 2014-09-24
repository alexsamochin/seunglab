#include "mex.h"
#include <iostream>
#include <cstdlib>
#include <boost/pending/disjoint_sets.hpp>
#include <vector>
#include <map>
#include <queue>
#include <set>
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
    


class classcomp{

    public:

    bool operator() (std::pair<std::pair <float, float>, float> p1, std::pair<std::pair <float, float>, float> p2) const 
    {	if (p1.second==p2.second){
		return (p1.first).first < (p2.first).first;
	}
        return p1.second > p2.second;
    }
};

//MAXIMUM spanning tree
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
    const mxArray * marker = prhs[2];
	const mwSize marker_num_dims = mxGetNumberOfDimensions(marker);
	const mwSize * marker_dims = mxGetDimensions(marker);
	const mwSize num_vertices = mxGetNumberOfElements(marker);
	const double * marker_data =(const double *)mxGetData(marker);
	const double low_threshold = (const double) mxGetScalar(prhs[3]);

	
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

	// create disjoint sets
	//   mwSize num_vertices = marker_num_elements;	//conn_dims[0]*conn_dims[1]*conn_dims[2];
    std::vector<mwSize> rank(num_vertices);
    std::vector<mwSize> parent(num_vertices);
    boost::disjoint_sets<mwSize*, mwSize*> dsets(&rank[0],&parent[0]);
    for (mwSize i=0; i<num_vertices; i++){
        dsets.make_set(i);
    }


	float largest_comp=0;

	// output array
    mxArray * label;
    mwSize label_num_dims=marker_num_dims;
    mwSize label_dims[label_num_dims];
    for (mwSize i=0; i<label_num_dims; i++){
        label_dims[i]=marker_dims[i];

    }
	plhs[0] = mxCreateNumericArray(label_num_dims,label_dims,mxSINGLE_CLASS,mxREAL);
    label=plhs[0];
	float * label_data =(float *)mxGetData(label);
    mwSize label_num_elements=mxGetNumberOfElements(label);


	//keep teack of comps for dendrogram
	//std::vector<float> comp_vector;

	// initialize output array and find representatives of each class
	std::map<float,mwSize> components;
    for (mwSize i=0; i<label_num_elements; i++){
        label_data[i]=marker_data[i];
		//cout << "Label: " << label_data[i]  << "," << marker_data[i] << endl;
		//comp_set.insert(marker_data[i]);
		if (label_data[i] > 0){
			components[label_data[i]] = i;
		}
		if (marker_data[i] > largest_comp){
			largest_comp=marker_data[i];
		}
    }

	// merge vertices labeled with the same marker
    for (mwSize i=0; i<label_num_elements; i++){
		if (label_data[i] > 0){
			dsets.union_set(components[label_data[i]],i);
		}
    }


	// sort the list of edges
    std::priority_queue <mwSize, vector<mwSize>, mycomp > pqueue (conn_data);
    for (mwSize i=0; i<conn_num_elements; i++){
		if (conn_data[i] > low_threshold){
	        pqueue.push(i);
		}
        /*cout << conn_data[i] << " " << i << endl;
        cout << "size is " << pqueue.size() << endl;
        cout << "top is " << pqueue.top() << endl << endl;*/
    }


	//initialize dendrogram disjoint sets
  	std::vector<mwSize> rank1((mwSize)largest_comp);
    std::vector<mwSize> parent1((mwSize)largest_comp);
    boost::disjoint_sets<mwSize*, mwSize*> den_dsets(&rank1[0],&parent1[0]);
    for (mwSize i=1; i<=(mwSize)largest_comp; i++){
        den_dsets.make_set(i);
    }

	std::vector < boost::tuple < float, float, float> > internal_dend;
	//internal_dend.reserve(num_vertices);
	std::map<float, float> parent_array;
	for (mwSize i=1; i<=(mwSize)largest_comp;i++){
		parent_array[i]=i;
	}
	
  	largest_comp++;


    while (!pqueue.empty()){
        float cur_edge=(float)pqueue.top();
		//lowest_edge=cur_edge;
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
            v2_array[i]+= (mwSize) nhood_data[nhood_dims[0]*i+edge_array[conn_num_dims-1]];
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
			float label_of_set1 = label_data[set1];
			float label_of_set2 = label_data[set2];
			mwSize den_set1=den_dsets.find_set(label_of_set1);
			mwSize den_set2=den_dsets.find_set(label_of_set2);
			if ((set1!=set2)
					&& (label_of_set1 >= 0)
					&& (label_of_set2 >= 0)){
				if ( (label_of_set1 == 0) || (label_of_set2 == 0) ){
					dsets.link(set1, set2);
					// funkiness: either label_of_set1 is 0 or label_of_set2 is 0.
					// so the sum of the two values should the value of the non-zero
					// using this trick to find the new label
					label_data[dsets.find_set(set1)] = label_of_set1+label_of_set2;
				}

				//write to dendrogram map if both labels are > 0
				else if ( (label_of_set1 > 0) && (label_of_set2 > 0)){
				//cout << "comp labels: " << label_of_set1 << ", " << label_of_set2 << endl;
					if (den_set1 != den_set2){
						float first=parent_array[(mwSize)den_dsets.find_set(label_of_set1)];
						float second = parent_array[(mwSize)den_dsets.find_set(label_of_set2)];
						internal_dend.push_back(boost::tuple < float, float, float> (first, second, conn_data[(mwSize)cur_edge]));
						den_dsets.link(den_set1, den_set2);
						parent_array[den_dsets.find_set(label_of_set1)]=largest_comp;

						largest_comp++;
						
					}
				}
            }


        }
    }



	// write out the final coloring
	for (mwSize i=0; i<label_num_elements; i++){
		label_data[i] = label_data[dsets.find_set(i)];
	}




	//mwSize num_comps=comp_set.size();



	//create dendrogram map
	//std::map < std::pair <float, float>, float> thresh_map;
	//mwSize lowest_edge;

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

	//cout << "got to this point" << endl;
	//printf("got to this point also\n");

    thresh=plhs[1];
    float * thresh_data=(float *)mxGetData(plhs[1]);    
    mwSize thresh_elements=mxGetNumberOfElements(thresh);





	mwSize place=0;
	std::vector<boost::tuple <float, float, float> >::iterator internal_dend_it;
	//cout << "map size is " << sorted_map.size() << endl;
	for (internal_dend_it=internal_dend.begin(); internal_dend_it!=internal_dend.end(); internal_dend_it++){
		/*std::pair <float, float> point_pair=(*internal_dend_it).first;
		float weight=(*internal_dend_it).second;

		mwSize pair_array[2];
		pair_array[0]=(mwSize)point_pair.first;
		pair_array[1]=(mwSize)point_pair.second;*/

		boost::tuple <float, float, float> tuple= *internal_dend_it;

		mwSize fst_pair[2];
		fst_pair[0]=place;
		fst_pair[1]=2;
		mwSize fst_loc=sub2ind(fst_pair, 2, thresh_dims);
		thresh_data[fst_loc]=tuple.get<2>();
		//cout << "weight " << weight << endl;


		mwSize trd_pair[2];
		trd_pair[0]=place;
		trd_pair[1]=0;
		mwSize trd_loc=sub2ind(trd_pair, 2, thresh_dims);
		//mwSize trd_comp=(pair_array[0]);
		thresh_data[trd_loc]=tuple.get<0>();
		//cout << trd_comp << endl;

		mwSize fth_pair[2];
		fth_pair[0]=place;
		fth_pair[1]=1;
		mwSize fth_loc=sub2ind(fth_pair, 2, thresh_dims);
		//mwSize fth_comp=(pair_array[1]);
		thresh_data[fth_loc]=tuple.get<1>();
		//cout << fth_comp << endl;

		place++;
	

	}
	

}

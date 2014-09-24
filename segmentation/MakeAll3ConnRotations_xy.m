% make and save 4 X-Y reflections of a 3 connected component set
function []=MakeAll3ConnRotations_xy(im, components, mask, fname, bb_train, bb_test, use_conn, extra_var)

rots{1}.im=fliplr_all(im);
rots{1}.components=fliplr_all(components);
rots{1}.extra_var=fliplr_all(extra_var);
rots{1}.mask=fliplr_all(mask);
rots{1}.bb_train=[bb_train(1,:); size(im,2)-bb_train(2,2), size(im,2)-bb_train(2,1); bb_train(3,:)];
rots{1}.bb_test=[bb_test(1,:); size(im,2)-bb_test(2,2), size(im,2)-bb_test(2,1); bb_test(3,:)];

rots{2}.im=flipud_all(im);
rots{2}.components=flipud_all(components);
rots{2}.extra_var=flipud_all(extra_var);
rots{2}.mask=flipud_all(mask);
rots{2}.bb_train=[size(im,1)-bb_train(1,2), size(im,1)-bb_train(1,1); bb_train(2,:); bb_train(3,:)];
rots{2}.bb_test=[size(im,1)-bb_test(1,2), size(im,1)-bb_test(1,1); bb_test(2,:); bb_test(3,:)];

rots{3}.im=fliplr_all(flipud_all(im));
rots{3}.components=fliplr_all(flipud_all(components));
rots{3}.extra_var=fliplr_all(flipud_all(extra_var));
rots{3}.mask=fliplr_all(flipud_all(mask));
rots{3}.bb_train=[size(im,1)-bb_train(1,2), size(im,1)-bb_train(1,1); size(im,2)-bb_train(2,2), size(im,2)-bb_train(2,1); bb_train(3,:)];
rots{3}.bb_test=[size(im,1)-bb_test(1,2), size(im,1)-bb_test(1,1); size(im,2)-bb_test(2,2), size(im,2)-bb_test(2,1); bb_test(3,:)];

rots{4}.im=im;
rots{4}.components=components;
rots{4}.extra_var=extra_var;
rots{4}.mask=mask;
rots{4}.bb_train=bb_train;
rots{4}.bb_test=bb_test;



for i=1:length(rots)

    i
        
    if(use_conn)
    	labels=MakeConn3Label(rots{i}.components);
    else
    	labels=rots{i}.components;
    end
    
    if(~isempty(rots{i}.extra_var))
	    labels(:,:,:,end+1)=rots{i}.extra_var;    
    end
    im=rots{i}.im;
    label_mask=repmat(rots{i}.mask, [1 1 1 size(labels,4) ]);
            
    label_name=[fname, '_labels_', num2str(i)];
    label_mask_name=[fname, '_label_mask_', num2str(i)];
    im_name=[fname, '_im_', num2str(i)];
    train_name=[fname, '_train_', num2str(i)];
        
    save(label_name, 'labels');
    save(im_name, 'im');
	save(label_mask_name, 'label_mask');
    
    bb=rots{i}.bb_train;
    im=im_name;
    labels=label_name;        
    label_mask=label_mask_name;
    
    save(train_name, 'bb', 'im', 'labels', 'label_mask');
    
    if(i==length(rots))	    
    	bb=rots{i}.bb_test;
    	test_name=[fname, '_test'];
    	save(test_name, 'bb', 'im', 'labels', 'label_mask');    	
    end
end

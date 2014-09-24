% make and save permutations of a 3 connected component file
function []=MakeAll3ConnRotations(im_orig, components, mask, fname, bb_train, bb_test, use_tanh, extra_var)

ps=perms([1:3]);

if(use_tanh)
	extra_var=extra_var*3-1.5;
end

for i=1:size(ps,1)
    
    i
    
    order=ps(i,:);
    
    labels=MakeConn3Label(permute(components,order));
    if(use_tanh)
        labels=labels*3-1.5;
    end
    labels(:,:,:,end+1)=permute(extra_var,order);
    
    im=permute(im_orig,order);
    label_mask=repmat(permute(mask, order),[1 1 1 size(labels,4)]);
    
    
    order
    size(im)
    
    for j=1:length(order)
        bb_train_r(j,:)=bb_train(order(j),:);
    end
            
    label_name=[fname, '_labels_', num2str(i)];
    label_mask_name=[fname, '_label_mask_', num2str(i)];
    im_name=[fname, '_im_', num2str(i)];
    train_name=[fname, '_train_', num2str(i)];
        
    save(label_name, 'labels');
    save(im_name, 'im');
	save(label_mask_name, 'label_mask');
    
    bb=bb_train_r;
    im=im_name;
    labels=label_name;        
    label_mask=label_mask_name;
    
    save(train_name, 'bb', 'im', 'labels', 'label_mask');
    
    if(order==[1 2 3])	    
    	bb=bb_test
    	test_name=[fname, '_test'];
    	save(test_name, 'bb', 'im', 'labels', 'label_mask');    	
    end
end
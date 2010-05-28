configuration conf of demo_tb is
  for behav
    for uut : demo_top 
    	use entity work.demo(behav);
    end for;
  end for;
end conf;
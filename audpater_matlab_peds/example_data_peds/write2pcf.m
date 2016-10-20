function write2pcf(File, In)

fid = fopen(File);
for i = 1:5
    tline{i} = fgetl(fid);
end
fclose(fid);

fid = fopen(File,'w');
for i = 1:5
    fprintf(fid,'%s\n',tline{i});
end 
fprintf(fid,'0, %1.1f, 0, 0, 0\n',In);
fclose(fid);



Article.delete_all

Article.create(
  id: 1,
  title: "My Very First Post",
  published_at: Time.now - 1.day,
  body: 
  %Q{### There Is Something You Should Know!

  This is my very first post using markdown!

  }
)

Article.create(
  id: 2,
  title: "My Second Post",
  published_at: Time.now,
  body: 
  %Q{### My List of Things To Do!

  Here is the list of things I wish to do!
  
  * write more posts
  * write even more posts
  * write even more posts!}
)

Article.create(
  id: 3,
  title: "Ruby Post",
  published_at: Time.now,
  body: 
  %Q{### My List of Things To Do!
``` ruby
some_code_here
```
 }
)

Article.create(
  id: 4,
  title: "Shell Post",
  published_at: Time.now,
  body: 
  %Q{### My List of Things To Do!
``` shell
#!/bin/ksh 
numDays=4
diff=86400*$numDays
export diff
newDate=$(perl -e 'use POSIX; print strftime "%Y%m%d%H%M", localtime time-$ENV{diff};')
lastFile=$(ls -lt | egrep -v ^d | tail -1 | awk ' { print $9 } ')
touch -t $newDate $lastFile
```
 }
)

Article.create(
  id: 5,
  title: "Shell Post 2",
  published_at: Time.now,
  body: 
  %Q{### My List of Things To Do!
``` shell
#!/bin/ksh
dir=/this/is/my/outputdir/
numGig=2.7
factor=1024
memLimit=$(expr $numGig*$factor*$factor*$factor | bc)
cd $dir
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 ; do
   dd if=/dev/urandom of=dummy_$i.xml count=204800 bs=$factor
done
```
 }
)



Article.create(
  id: 6,
  title: "Shell Post 3",
  published_at: Time.now,
  body: 
  %Q{### My List of Things To Do!
``` shell
awk '{print $1}' ~/.bash_history | sort | uniq -c | sort -n
```
 }
)
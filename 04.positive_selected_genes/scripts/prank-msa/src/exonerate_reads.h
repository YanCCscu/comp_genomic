#ifndef EXONERATE_READS_H
#define EXONERATE_READS_H

#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <sys/stat.h>

extern std::string tempdir;

struct hit
{
    std::string query;
    std::string node;
    int score;
    int q_start;
    int q_end;
    char q_strand;
    int t_start;
    int t_end;
    char t_strand;
};

class Exonerate_reads
{
    static bool better (hit i,hit j)
    {
        return (i.score>j.score);
    }
    static bool q_earlier (hit i,hit j)
    {
        return (i.q_start<j.q_start);
    }

    bool split_sugar_string(const std::string& row,hit *h);
    void delete_files(int r);

    std::string get_temp_dir()
    {
        std::string tmp_dir = "/tmp/";
        if(tempdir != "")
            tmp_dir = tempdir+"/";

        struct stat st;
        if(stat(tmp_dir.c_str(),&st) != 0)
            tmp_dir = "";

        return tmp_dir;
    }

public:
    Exonerate_reads();
    bool test_executable();

    void local_alignment(std::string* left,std::string* right, std::vector<hit> *hits, bool is_local);

};

#endif // EXONERATE_READS_H

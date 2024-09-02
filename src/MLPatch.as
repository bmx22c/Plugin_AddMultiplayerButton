class APatch {
    string find;
    string replace;

    APatch(const string &in find, const string &in replace) {
        this.find = find;
        this.replace = replace;
    }

    string Apply(const string &in src) {
        return src.Replace(find, replace);
    }
}

class AppendPatch : APatch {
    AppendPatch(const string &in find, const string &in append) {
        super(find, find + append);
    }
}

class PrependPatch : APatch {
    PrependPatch(const string &in find, const string &in prepend) {
        super(find, prepend + find);
    }
}

class APatchSet {
    array<APatch@> patches;

    void AddPatch(const string &in find, const string &in replace) {
        patches.InsertLast(APatch(find, replace));
    }

    void AddPatch(APatch@ patch) {
        patches.InsertLast(patch);
    }

    string Apply(const string &in src) {
        string result = src;
        for (uint i = 0; i < patches.Length; i++) {
            result = patches[i].Apply(result);
        }
        return result;
    }
}
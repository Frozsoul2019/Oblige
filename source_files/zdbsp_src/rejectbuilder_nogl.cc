// This is the same algorithm used by DoomBSP:
//
// Represent each sector by its bounding box. Then for each pair of
// sectors, see if any chains of one-sided lines can walk from one
// side of the convex hull for that pair to the other side.
//
// It works, but it's far from being perfect. It's quite easy for
// this algorithm to consider two sectors as being visible from
// each other when they are really not. But it won't erroneously
// flag two sectors as obstructed when they're really not, and that's
// the only thing that really matters when building a REJECT lump.

#include "rejectbuilder_nogl.h"

#include <stdio.h>
#include <string.h>

#include "templates.h"

FRejectBuilderNoGL::FRejectBuilderNoGL(FLevel &level)
    : Level(level), BlockChains(NULL) {
    RejectSize = (Level.NumSectors() * Level.NumSectors() + 7) / 8;
    Reject = new BYTE[RejectSize];
    memset(Reject, 0, RejectSize);

    FindSectorBounds();
    FindBlockChains();
    BuildReject();
}

FRejectBuilderNoGL::~FRejectBuilderNoGL() {
    FBlockChain *chain, *next;

    chain = BlockChains;
    while (chain != NULL) {
        next = chain->Next;
        delete chain;
        chain = next;
    }
}

BYTE *FRejectBuilderNoGL::GetReject() { return Reject; }

void FRejectBuilderNoGL::FindSectorBounds() {
    int i;

    SectorBounds = new BBox[Level.NumSectors()];

    for (i = 0; i < Level.NumSectors(); ++i) {
        SectorBounds[i].Bounds[LEFT] = SectorBounds[i].Bounds[BOTTOM] = INT_MAX;
        SectorBounds[i].Bounds[RIGHT] = SectorBounds[i].Bounds[TOP] = INT_MIN;
    }

    for (i = 0; i < Level.NumLines(); ++i) {
        if (Level.Lines[i].sidenum[0] != NO_INDEX) {
            int secnum = Level.Sides[Level.Lines[i].sidenum[0]].sector;
            SectorBounds[secnum].AddPt(Level.Vertices[Level.Lines[i].v1]);
            SectorBounds[secnum].AddPt(Level.Vertices[Level.Lines[i].v2]);
        }
        if (Level.Lines[i].sidenum[1] != NO_INDEX) {
            int secnum = Level.Sides[Level.Lines[i].sidenum[1]].sector;
            SectorBounds[secnum].AddPt(Level.Vertices[Level.Lines[i].v1]);
            SectorBounds[secnum].AddPt(Level.Vertices[Level.Lines[i].v2]);
        }
    }
}

void FRejectBuilderNoGL::FindBlockChains() {
    bool *marked = new bool[Level.NumLines()];
    DWORD *nextForVert = new DWORD[Level.NumLines()];
    DWORD *firstLine = new DWORD[Level.NumVertices];
    int i, j, k;
    FBlockChain *chain;
    FPoint pt;
    TArray<FPoint> pts;

    memset(nextForVert, 0xff, Level.NumLines() * sizeof(*nextForVert));
    memset(firstLine, 0xff, Level.NumVertices * sizeof(*firstLine));
    memset(marked, 0, Level.NumLines() * sizeof(*marked));

    for (i = 0; i < Level.NumLines(); ++i) {
        if (Level.Lines[i].sidenum[0] == NO_INDEX ||
            Level.Lines[i].sidenum[1] != NO_INDEX) {
            marked[i] = true;
        } else {
            nextForVert[Level.Lines[i].v1] = firstLine[Level.Lines[i].v1];
            firstLine[Level.Lines[i].v1] = i;
        }
    }

    for (i = 0; i < Level.NumLines(); ++i) {
        if (marked[i]) {
            continue;
        }

        pt.x = Level.Vertices[Level.Lines[i].v1].x >> FRACBITS;
        pt.y = Level.Vertices[Level.Lines[i].v1].y >> FRACBITS;
        pts.Clear();
        pts.Push(pt);
        chain = new FBlockChain;
        chain->Bounds(LEFT) = chain->Bounds(RIGHT) = pt.x;
        chain->Bounds(TOP) = chain->Bounds(BOTTOM) = pt.y;

        for (j = i; j != NO_INDEX;) {
            marked[j] = true;
            pt.x = Level.Vertices[Level.Lines[j].v2].x >> FRACBITS;
            pt.y = Level.Vertices[Level.Lines[j].v2].y >> FRACBITS;
            pts.Push(pt);
            chain->Bounds.AddPt(pt);

            k = firstLine[Level.Lines[j].v2];
            if (k == NO_INDEX) {
                break;
            }
            if (nextForVert[k] == NO_INDEX) {
                j = marked[k] ? NO_INDEX : k;
            } else {
                int best = NO_INDEX;
                angle_t bestang = ANGLE_MAX;
                angle_t ang1 =
                    PointToAngle(Level.Vertices[Level.Lines[j].v2].x -
                                     Level.Vertices[Level.Lines[j].v1].x,
                                 Level.Vertices[Level.Lines[j].v2].y -
                                     Level.Vertices[Level.Lines[j].v1].y) +
                    (1 << 31);

                while (k != NO_INDEX) {
                    if (!marked[k]) {
                        angle_t ang2 =
                            PointToAngle(
                                Level.Vertices[Level.Lines[k].v2].x -
                                    Level.Vertices[Level.Lines[k].v1].x,
                                Level.Vertices[Level.Lines[k].v2].y -
                                    Level.Vertices[Level.Lines[k].v1].y) +
                            (1 << 31);
                        angle_t angdiff = ang2 - ang1;

                        if (angdiff < bestang && angdiff > 0) {
                            bestang = angdiff;
                            best = k;
                        }
                    }
                    k = nextForVert[k];
                }

                j = best;
            }
        }

        chain->NumPoints = pts.Size();
        chain->Points = new FPoint[chain->NumPoints];
        memcpy(chain->Points, &pts[0],
               chain->NumPoints * sizeof(*chain->Points));
        chain->Next = BlockChains;
        BlockChains = chain;
    }
}

void FRejectBuilderNoGL::HullSides(const BBox &box1, const BBox &box2,
                                   FPoint sides[4]) {
    static const int vertSides[4][2] = {
        {LEFT, BOTTOM}, {LEFT, TOP}, {RIGHT, TOP}, {RIGHT, BOTTOM}};
    static const int stuffSpots[4] = {0, 3, 2, 1};

    const int *boxp1, *boxp2;

    boxp1 = box2.Bounds;
    boxp2 = box1.Bounds;

    for (int mainBox = 2; mainBox != 0;) {
        const int *stuffs = stuffSpots + (--mainBox) * 2;
        int outerEdges[4];

        outerEdges[LEFT] = boxp1[LEFT] <= boxp2[LEFT];
        outerEdges[TOP] = boxp1[TOP] >= boxp2[TOP];
        outerEdges[RIGHT] = boxp1[RIGHT] >= boxp2[RIGHT];
        outerEdges[BOTTOM] = boxp1[BOTTOM] <= boxp2[BOTTOM];

        for (int vertex = 0; vertex < 4; ++vertex) {
            if (outerEdges[(vertex - 1) & 3] != outerEdges[vertex]) {
                FPoint *pt = &sides[stuffs[outerEdges[vertex]]];
                pt->x = boxp1[vertSides[vertex][0]];
                pt->y = boxp1[vertSides[vertex][1]];
            }
        }

        boxp1 = box1.Bounds;
        boxp2 = box2.Bounds;
    }
}

int FRejectBuilderNoGL::PointOnSide(const FPoint *pt, const FPoint &lpt1,
                                    const FPoint &lpt2) {
    return (pt->y - lpt1.y) * (lpt2.x - lpt1.x) >=
           (pt->x - lpt1.x) * (lpt2.y - lpt1.y);
}

bool FRejectBuilderNoGL::ChainBlocks(const FBlockChain *chain,
                                     const BBox *hullBounds,
                                     const FPoint *hullPts) {
    int startSide, side, i;

    if (chain->Bounds[LEFT] > hullBounds->Bounds[RIGHT] ||
        chain->Bounds[RIGHT] < hullBounds->Bounds[LEFT] ||
        chain->Bounds[TOP] < hullBounds->Bounds[BOTTOM] ||
        chain->Bounds[BOTTOM] > hullBounds->Bounds[TOP]) {
        return false;
    }

    startSide = -1;

    for (i = 0; i < chain->NumPoints; ++i) {
        const FPoint *pt = &chain->Points[i];

        if (PointOnSide(pt, hullPts[1], hullPts[2])) {
            startSide = -1;
            continue;
        }
        if (PointOnSide(pt, hullPts[3], hullPts[0])) {
            startSide = -1;
            continue;
        }
        if (PointOnSide(pt, hullPts[0], hullPts[1])) {
            side = 0;
        } else if (PointOnSide(pt, hullPts[2], hullPts[3])) {
            side = 1;
        } else {
            continue;
        }
        if (startSide == -1 || startSide == side) {
            startSide = side;
        } else {
            return true;
        }
    }

    return false;
}

void FRejectBuilderNoGL::BuildReject() {
    int s1, s2;

    for (s1 = 0; s1 < Level.NumSectors() - 1; ++s1) {
        printf("   Reject: %3d%%\r", s1 * 100 / Level.NumSectors());
        for (s2 = s1 + 1; s2 < Level.NumSectors(); ++s2) {
            BBox HullBounds;
            FPoint HullPts[4];
            const BBox *sb1, *sb2;

            sb1 = &SectorBounds[s1];
            sb2 = &SectorBounds[s2];

            int pos = s1 * Level.NumSectors() + s2;
            if (Reject[pos >> 3] & (1 << (pos & 7))) {
                continue;
            }

            // Overlapping and touching sectors are considered to always
            // see each other.
            if (sb1->Bounds[LEFT] <= sb2->Bounds[RIGHT] &&
                sb1->Bounds[RIGHT] >= sb2->Bounds[LEFT] &&
                sb1->Bounds[TOP] >= sb2->Bounds[BOTTOM] &&
                sb1->Bounds[BOTTOM] <= sb2->Bounds[TOP]) {
                continue;
            }

            HullBounds(LEFT) = MIN(sb1->Bounds[LEFT], sb2->Bounds[LEFT]);
            HullBounds(RIGHT) = MAX(sb1->Bounds[RIGHT], sb2->Bounds[RIGHT]);
            HullBounds(BOTTOM) = MIN(sb1->Bounds[BOTTOM], sb2->Bounds[BOTTOM]);
            HullBounds(TOP) = MAX(sb1->Bounds[TOP], sb2->Bounds[TOP]);

            HullSides(*sb1, *sb2, HullPts);

            for (FBlockChain *chain = BlockChains; chain != NULL;
                 chain = chain->Next) {
                if (ChainBlocks(chain, &HullBounds, HullPts)) {
                    break;
                }
            }

            Reject[pos >> 3] |= 1 << (pos & 7);
            pos = s2 * Level.NumSectors() + s1;
            Reject[pos >> 3] |= 1 << (pos & 7);
        }
    }
    printf("   Reject: 100%%\n");
}

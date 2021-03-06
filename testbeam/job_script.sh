
function setup_nova_grid {
  source /cvmfs/nova.opensciencegrid.org/novasoft/slf6/novasoft/setup/setup_nova.sh "$@"
}

setup_nova_grid -r S18-01-19 -6 /cvmfs/nova.opensciencegrid.org/novasoft/slf6/novasoft -e /cvmfs/nova.opensciencegrid.org/externals -b maxopt
setup G4beamline v3_04

export G4BL_DIR=/cvmfs/nova.opensciencegrid.org/externals/G4beamline/v3_04
export G4ABLADATA=/cvmfs/nova.opensciencegrid.org/externals/g4abla/v3_0/NULL/G4ABLA3.0
export G4LEDATA=/cvmfs/nova.opensciencegrid.org/externals/g4emlow/v6_50/G4EMLOW6.50
export G4ENSDFSTATEDATA=/cvmfs/nova.opensciencegrid.org/externals/g4nuclide/v2_1/G4ENSDFSTATE2.1
export G4NEUTRONHPDATA=/cvmfs/nova.opensciencegrid.org/externals/g4neutron/v4_5/NULL/G4NDL4.5
export G4NEUTRONXSDATA=/cvmfs/nova.opensciencegrid.org/externals/g4neutronxs/v1_4/NULL/G4NEUTRONXS1.4
export G4PIIDATA=/cvmfs/nova.opensciencegrid.org/externals/g4pii/v1_3/NULL/G4PII1.3
export G4SAIDXSDATA=/cvmfs/nova.opensciencegrid.org/externals/g4nucleonxs/v1_1/NULL/G4SAIDDATA1.1
export G4LEVELGAMMADATA=/cvmfs/nova.opensciencegrid.org/externals/g4photon/v4_3_2/PhotonEvaporation4.3.2
export G4RADIOACTIVEDATA=/cvmfs/nova.opensciencegrid.org/externals/g4radiative/v5_1_1/RadioactiveDecay5.1.1
export G4REALSURFACEDATA=/cvmfs/nova.opensciencegrid.org/externals/g4surface/v1_0/NULL/RealSurface1.0

PROCESS_START=0
# PROCESS_START=10000
# PROCESS_START=20000
# PROCESS_START=30000
# B_FIELD=-0.225
# B_FIELD=-0.45
# B_FIELD=-0.675
B_FIELD=-0.9
# B_FIELD=-1.125
# B_FIELD=-1.35
# B_FIELD=-1.575
# B_FIELD=-1.8
# B_FIELD=0.225
# B_FIELD=0.45
# B_FIELD=0.675
# B_FIELD=0.9
# B_FIELD=1.125
# B_FIELD=1.35
# B_FIELD=1.575
# B_FIELD=1.8

ifdh cp /pnfs/nova/persistent/users/junting/testbeam/merge_tree.py ./merge_tree.py
ifdh cp /pnfs/nova/persistent/users/junting/testbeam/beamline.py.in ./beamline.py.in

PARTICLE=proton
MOMENTUM=64000
EVENT_COUNT_PER_JOB=20000
JOB_COUNT_PER_SPILL=50
FIRST=$((((${PROCESS_START} + ${PROCESS}))* ${EVENT_COUNT_PER_JOB}))
LAST=$((${FIRST} + $EVENT_COUNT_PER_JOB - 1))
echo "PROCESS is: $PROCESS"
echo "EVENT_COUNT_PER_JOB is: $EVENT_COUNT_PER_JOB"
echo "FIRST = $FIRST"
echo "LAST = $LAST"
JOB_COUNT=$((${PROCESS_START} + ${PROCESS} + 1))
EVENT_COUNT_PER_SPILL=$((${EVENT_COUNT_PER_JOB} * ${JOB_COUNT_PER_SPILL}))

g4bl beamline.py.in first=${FIRST} last=${LAST} particle=${PARTICLE} momentum=${MOMENTUM} b_field=${B_FIELD}
python merge_tree.py beam.root --subspill_number $JOB_COUNT --subspill_count $JOB_COUNT_PER_SPILL --spill_size $EVENT_COUNT_PER_SPILL
chmod 766 merge_tree.root
ifdh cp merge_tree.root /pnfs/nova/scratch/users/junting/g4bl.b_${B_FIELD}T.${PARTICLE}.${MOMENTUM}.merge_tree.root.${JOB_COUNT}.root

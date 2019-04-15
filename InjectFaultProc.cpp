//===----------------------------------------------------------------------===//
//
//                       LLVM Fault Injection Tool
//
//===----------------------------------------------------------------------===//
//
//  Copyright (C) 2019. rollrat. All Rights Reserved.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Demangle/Demangle.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Pass.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/raw_ostream.h"
#include <map>
#include <random>
#include <set>
#include <sstream>
#include <string>

#define DEBUG_TYPE "fault-injection"

#define MARK_FUNCTION_NAME "__marking_faultinject"
#define IGNORE_ZERO_SIZE 1
#define USE_RAW_INJECT 1

using namespace llvm;

namespace {

class FaultInjectionMachine {
public:

  static void insertInjectFault(Module &M, Function &F, CallInst *CI) {
    std::mt19937 rng;
    rng.seed(std::random_device()());
    std::uniform_int_distribution<std::mt19937::result_type> dist(0, 31);
    unsigned int loc = 1ULL << dist(rng);

    IntegerType *type = Type::getInt32Ty(M.getContext());
    AllocaInst *xor_marker =
        new AllocaInst(type, M.getDataLayout().getProgramAddressSpace(),
                       "xor_marker", &*F.getEntryBlock().begin());
    Value *num = ConstantInt::get(type, loc, true);
    new StoreInst(num, xor_marker, &*++F.getEntryBlock().begin());

    Value *num_zero = ConstantInt::get(type, 0, true);
    StoreInst *resetter = new StoreInst(num_zero, xor_marker, CI->getNextNode());
    LoadInst *val = new LoadInst(xor_marker, "xor_val", resetter);
    BinaryOperator *fi =
    BinaryOperator::CreateXor(CI->getOperand(0), val, "rfi", val->getNextNode());

    std::list<User *> inst_uses;
    for (Value::user_iterator user_it = CI->user_begin();
         user_it != CI->user_end(); ++user_it) {
      User *user = *user_it;
      if (user != CI && user != fi)
        inst_uses.push_back(user);
    }
    for (std::list<User *>::iterator use_it = inst_uses.begin();
         use_it != inst_uses.end(); ++use_it) {
      User *user = *use_it;
      user->replaceUsesOfWith(CI, fi);
    }

    CI->eraseFromParent();
  }
};

struct LLVMInjectFaultPass : public ModulePass {
  static char ID;

  LLVMInjectFaultPass() : ModulePass(ID) {}

  ~LLVMInjectFaultPass() {}

  bool runOnModule(Module &M) override {
    for (Module::iterator m_it = M.begin(); m_it != M.end();
         ++m_it) {
      std::vector<CallInst *> mm;
      for (auto &bb : *m_it)
        for (auto &inst : bb)
          if (CallInst *call = dyn_cast<CallInst>(&inst))
            if (call->getCalledFunction()->getName().startswith("__faultinject_selected_target"))
              mm.push_back(call);
      for (auto& CI : mm)
        FaultInjectionMachine::insertInjectFault(M, *m_it, CI);
    }
  }
};

}

char LLVMInjectFaultPass::ID = 0;

static RegisterPass<LLVMInjectFaultPass> X("injectfault",
                                              "Inject Fault Pass",
                                              false /* Only looks at CFG */,
                                              false /* Analysis Pass */);
